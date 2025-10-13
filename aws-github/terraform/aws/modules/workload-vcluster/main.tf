data "aws_ssm_parameter" "cluster" {
  provider = aws.business_mgmt_region
  name = "/clusters/${var.host_cluster}"
}

data "aws_eks_cluster" "cluster" {
  name = var.host_cluster
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

locals {
  vcluster_host = "${var.vcluster_name}.${var.domain_name}"
  
  original_kubeconfig = data.kubernetes_secret.vcluster_kubeconfig.data["config"]
  
  modified_kubeconfig = replace(
    local.original_kubeconfig,
    "/server:\\s*https://[^:]+(?::\\d+)?/",
    "server: https://${local.vcluster_host}"
  )
}

data "helm_repository" "loft" {
  name = "loft"
  url  = "https://charts.loft.sh"
}

resource "helm_release" "my_vcluster" {
  name             = var.vcluster_name
  namespace        = var.vcluster_name
  create_namespace = true

  repository       = data.helm_repository.loft.url
  chart            = "vcluster"
  version          = "0.28.0" # must exist in the repo

  values = [
    templatefile("${path.module}/values.yaml", {
      vcluster_name = var.vcluster_name
      domain_name   = var.domain_name
    })
  ]
}

data "kubernetes_secret" "vcluster_kubeconfig" {
  depends_on = [helm_release.my_vcluster]
  
  metadata {
    name      = "vc-${var.vcluster_name}"
    namespace = var.vcluster_name
  }
}

resource "kubernetes_secret" "example" {
  depends_on = [data.kubernetes_secret.vcluster_kubeconfig]
  provider   = kubernetes.incluster
  
  metadata {
    name      = "vc-${var.vcluster_name}"
    namespace = var.vcluster_name
  }

  data = {
    config = local.modified_kubeconfig
  }
}

provider "kubernetes" {
    host = data.vault_generic_secret.cluster.data["host"]
    token                  = data.aws_eks_cluster_auth.cluster.token
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
