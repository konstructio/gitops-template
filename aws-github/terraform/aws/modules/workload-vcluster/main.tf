data "vault_generic_secret" "cluster" {
  path = "secret/clusters/${var.host_cluster}"
}

data "vault_generic_secret" "vcluster" {
  depends_on = [kubernetes_job.post-creation]
  path = "secret/clusters/${var.vcluster_name}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.host_cluster
}

provider "helm" {
    kubernetes = {
        host                   = data.vault_generic_secret.cluster.data["host"]
        token                  = data.aws_eks_cluster_auth.cluster.token
        cluster_ca_certificate = data.vault_generic_secret.cluster.data["cluster_ca_certificate"]
    }   
}

resource "helm_release" "my_vcluster" {
  name             = var.vcluster_name
  namespace        = var.vcluster_name
  create_namespace = true

  repository       = "https://charts.loft.sh"
  chart            = "vcluster"
  version          = "0.24.0"

  values = [
    templatefile("${path.module}/values.yaml", {
      vcluster_name = var.vcluster_name
      domain_name   = var.domain_name
    })
  ]
}


provider "kubernetes" {
    host = data.vault_generic_secret.cluster.data["host"]
    client_certificate = data.vault_generic_secret.cluster.data["client_certificate"]
    client_key = data.vault_generic_secret.cluster.data["client_key"]
    cluster_ca_certificate = data.vault_generic_secret.cluster.data["cluster_ca_certificate"]
}

resource "kubernetes_role" "secret_reader" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name      = "secret-reader-${var.vcluster_name}"
    namespace = var.host_cluster 
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "allow_secret_access" {
  depends_on = [kubernetes_role.secret_reader]
  metadata {
    name      = "allow-secret-access-${var.vcluster_name}"
    namespace = var.host_cluster
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vcluster_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.secret_reader.metadata[0].name
  }
}

resource "kubernetes_role" "secret_reader_vcluster" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name      = "secret-reader-${var.vcluster_name}"
    namespace = var.vcluster_name 
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get"]
  }

}

resource "kubernetes_role_binding" "allow_secret_access_vcluster" {
  depends_on = [kubernetes_role.secret_reader]
  metadata {
    name      = "allow-secret-access-${var.vcluster_name}"
    namespace = var.vcluster_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vcluster_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.secret_reader_vcluster.metadata[0].name
  }
}

resource "kubernetes_service_account" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
}

resource "kubernetes_role" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments","statefulsets"]
    verbs          = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-toolkit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
}

resource "kubernetes_job" "post-creation" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "post-creation"
    namespace = "${var.vcluster_name}"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "post-creation"
          image   = "jokesta/vcluster-job"
          env {
            name  = "IN_CLUSTER"
            value = "true"
          }

          env {
            name  = "MGMT_CLUSTER_NAME"
            value = var.host_cluster
          }

          env {
            name  = "VCLUSTER_NAME"
            value = var.vcluster_name
          }

          env {
            name  = "VAULT_DOMAIN"
            value = var.vault_domain
          }
        }
        restart_policy = "OnFailure"
      }
    }
    backoff_limit = 20
  }
  wait_for_completion = true
}

provider "kubernetes" {
  alias = "incluster"
}

resource "kubernetes_secret" "example" {
  depends_on = [kubernetes_job.post-creation]
  provider = kubernetes.incluster
  metadata {
    name      = "vc-${var.vcluster_name}"
    namespace = "${var.vcluster_name}"
  }

   data = {
    config = (data.vault_generic_secret.vcluster.data["kubeconfig"])
  }

}
