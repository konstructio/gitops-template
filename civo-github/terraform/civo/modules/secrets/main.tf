// Create in-cluster Secret containing kubeconfig
// Referenced by dependent apps during setup
provider "kubernetes" {
  config_path = var.kube_config_path
}

// Kubefirst
resource "kubernetes_secret_v1" "civo_cluster_kubeconfig_kubefirst_ns" {
  metadata {
    name      = "kube-config-ref"
    namespace = "kubefirst"
  }

  data = {
    ".kubeconfig" = var.kube_config_content
  }

  type = "Opaque"
}

// Atlantis
resource "kubernetes_secret_v1" "civo_cluster_kubeconfig_atlantis_ns" {
  metadata {
    name      = "kube-config-ref"
    namespace = "atlantis"
  }

  data = {
    ".kubeconfig" = var.kube_config_content
  }

  type = "Opaque"
}
