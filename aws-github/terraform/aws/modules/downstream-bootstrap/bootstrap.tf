data "aws_ssm_parameter" "cluster" {
  name = "/clusters/${var.cluster_name}"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}


locals {
  cluster_config = jsondecode(data.aws_ssm_parameter.cluster.value)
}

provider "kubernetes" {
  host                   = local.cluster_config.host
  cluster_ca_certificate = base64decode(local.cluster_config.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_namespace_v1" "external_secrets_operator" {
  metadata {
    name = "external-secrets-operator"
  }
}

resource "kubernetes_namespace_v1" "environment" {
  metadata {
    name = var.cluster_name
  }
}

resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
  }
  secret {
    name = "external-secrets-token"
  }
}

resource "kubernetes_secret_v1" "external_secrets" {
  metadata {
    name      = "external-secrets-token"
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
    annotations = {
      "kubernetes.io/service-account.name" = "external-secrets"
    }
  }
  type       = "kubernetes.io/service-account-token"
  depends_on = [kubernetes_service_account_v1.external_secrets]
}

resource "kubernetes_config_map" "kubefirst_cm" {
  metadata {
    name      = "kubefirst-cm"
    namespace = "kube-system"
  }

  data = {
    mgmt_cluster_id = "8ikfaj"
  }
}
