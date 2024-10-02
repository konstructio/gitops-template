# Configuration used to install the GPU operator

locals {
  gpu_node_sizes = [for i in data.civo_size.gpu.sizes : i.name]
  gpu_prefixes   = ["g4g.", "an."] # Civo GPU sizes start with these prefixes - ensure to end with "." to avoid false positives
  is_gpu         = contains(local.gpu_node_sizes, var.node_type)
}

# Get all the GPU node types
data "civo_size" "gpu" {
  filter {
    key      = "name"
    values   = local.gpu_prefixes
    match_by = "re"
  }
  filter {
    key    = "type"
    values = ["kubernetes"]
  }
}

# Create labels for the GPU operator namespace
resource "kubernetes_namespace_v1" "gpu_operator_labels" {
  count = local.is_gpu ? 1 : 0
  metadata {
    name = "gpu-operator"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

# Helm release configuration for the Nvidia GPU operator
resource "helm_release" "gpu_operator" {
  count           = local.is_gpu ? 1 : 0
  name            = "gpu-operator"
  repository      = "https://helm.ngc.nvidia.com/nvidia"
  chart           = "gpu-operator"
  namespace       = kubernetes_namespace_v1.gpu_operator_labels[count.index].metadata[0].name
  version         = "v24.6.0"
  atomic          = true
  cleanup_on_fail = true
  reset_values    = true
  wait            = true
  # Values taken from Civo GPU operator
  # @link https://github.com/civo-learn/civo-gpu-operator-tf/blob/cdb5bc6ac3d278e3a0285178c4960611639bf196/infra/tf/values/gpu-operator-values.yaml
  values = [
    yamlencode({
      # set replica false as feature discovery remains pending
      wait = true

      ## Node Feature Discovery enabled/disable configuration.
      nfd = {
        enabled = true
      }

      # GPU Feature Discovery configuration.
      gfd = {
        enabled = true
      }

      # Operator configuration.
      operator = {
        upgradeCRD = true
        cleanupCRD = true
        resources = {
          requests = {
            cpu    = "10m"
            memory = "100Mi"
          }
          limits = {
            cpu    = "50m"
            memory = "300Mi"
          }
        }
      }

      # Node Feature Discovery configuration.
      node-feature-discovery = {
        enableNodeFeatureApi = true
        master = {
          resources = {
            requests = {
              cpu    = "10m"
              memory = "200Mi"
            }
          }
        }
        worker = {
          resources = {
            requests = {
              cpu    = "10m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "50m"
              memory = "300Mi"
            }
          }
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [
                  {
                    matchExpressions = [
                      {
                        key      = "node.kubernetes.io/instance-type"
                        operator = "In"
                        values   = local.gpu_node_sizes
                      }
                    ]
                  }
                ]
              }
            }
          }
          tolerations = [
            {
              key      = "nvidia.com/gpu"
              operator = "Exists"
              effect   = "NoSchedule"
            }
          ]
        }
        gc = {
          enable   = false
          interval = "30m"
          resources = {
            requests = {
              cpu    = "10m"
              memory = "100Mi"
            }
          }
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [
                  {
                    matchExpressions = [
                      {
                        key      = "node.kubernetes.io/instance-type"
                        operator = "NotIn"
                        values   = local.gpu_node_sizes
                      }
                    ]
                  }
                ]
              }
            }
          }
          tolerations = [
            {
              key      = "nvidia.com/gpu"
              operator = "Exists"
              effect   = "NoSchedule"
            }
          ]
        }
      }

      # Driver configuration
      driver = {
        enabled = false
      }

      # Toolkit configuration.
      toolkit = {
        enabled = false
      }

      # Device Plugin configuration.
      devicePlugin = {
        enabled = true
        version = "v0.14.5"
        env = [
          {
            name  = "FAIL_ON_INIT_ERROR"
            value = "false"
          }
        ]
      }

      # DCGM configuration
      dcgm = {
        # enable with monitoring
        enabled = false
        resources = {
          requests = {
            cpu    = "10m"
            memory = "100Mi"
          }
          limits = {
            cpu    = "50m"
            memory = "400Mi"
          }
        }
      }

      # DCGM Exporter configuration.
      dcgmExporter = {
        # enable with monitoring
        enabled = false
      }

      # MIG Manager configuration.
      migManager = {
        # @skip civo-talos-gpu-operator.migManager.enabled
        enabled = false
      }
      validator = {
        enabled = false
      }
    })
  ]
}
# as the host driver and the nvidia container toolkit are provided within Talos as Shims,
# we need to create a daemonset that forces these to be marked as ready for the GPU operator
# TODO: "productionise" this
resource "kubernetes_daemonset" "fake_toolkit_ready" {
  count = local.is_gpu ? 1 : 0
  metadata {
    name      = "fake-toolkit-ready"
    namespace = kubernetes_namespace_v1.gpu_operator_labels[count.index].metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        "k8s-app" = "fake-toolkit-ready"
      }
    }
    template {
      metadata {
        labels = {
          name      = "fake-toolkit-ready"
          "k8s-app" = "fake-toolkit-ready"
        }
      }
      spec {
        volume {
          name = "run-nvidia"
          host_path {
            path = "/run/nvidia/validations/"
          }
        }
        container {
          name    = "main"
          image   = "alpine:3.19"
          command = ["sh", "-c"]
          args = [
            <<-EOF
            set -ex;
            touch /run/nvidia/validations/host-driver-ready;
            touch /run/nvidia/validations/toolkit-ready;
            touch /run/nvidia/validations/.driver-ctr-ready;
            touch /run/nvidia/validations/driver-ready
            sleep infinity
            EOF
          ]
          volume_mount {
            name              = "run-nvidia"
            mount_path        = "/run/nvidia/validations/"
            mount_propagation = "HostToContainer"
          }
          image_pull_policy = "IfNotPresent"
        }
        restart_policy = "Always"
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node.kubernetes.io/instance-type"
                  operator = "In"
                  values   = local.gpu_node_sizes
                }
              }
            }
          }
        }
        toleration {
          key      = "nvidia.com/gpu"
          operator = "Exists"
          effect   = "NoSchedule"
        }
        priority_class_name = "system-node-critical"
      }
    }
  }
  depends_on = [helm_release.gpu_operator]
}
