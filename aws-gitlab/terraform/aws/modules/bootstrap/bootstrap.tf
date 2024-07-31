
data "vault_generic_secret" "cluster" {
  path = "secret/clusters/${var.cluster_name}"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.vault_generic_secret.cluster.data["host"]
  cluster_ca_certificate = base64decode(data.vault_generic_secret.cluster.data["cluster_ca_certificate"])
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

data "vault_generic_secret" "external_dns" {
  path = "secret/external-dns"
}

resource "kubernetes_secret_v1" "external_dns" {
  metadata {
    name      = "external-dns-secrets"
    namespace = kubernetes_namespace_v1.external_dns.metadata.0.name
  }
  data = {
    token = data.vault_generic_secret.external_dns.data["token"]
  }
  type = "Opaque"
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

data "vault_generic_secret" "docker_config" {
  path = "secret/dockerconfigjson"
}

resource "kubernetes_secret_v1" "image_pull" {
  metadata {
    name      = "docker-config"
    namespace = kubernetes_namespace_v1.environment.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = data.vault_generic_secret.docker_config.data["dockerconfig"]
  }

  type = "kubernetes.io/dockerconfigjson"
}

data "vault_generic_secret" "external_secrets_operator" {
  path = "secret/atlantis"
}

resource "kubernetes_secret_v1" "external_secrets_operator_environment" {
  metadata {
    name      = "${var.cluster_name}-cluster-vault-bootstrap"
    namespace = kubernetes_namespace_v1.environment.metadata.0.name
  }
  data = {
    vault-token = data.vault_generic_secret.external_secrets_operator.data["VAULT_TOKEN"]
  }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "external_secrets_operator" {
  metadata {
    name      = "${var.cluster_name}-cluster-vault-bootstrap"
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
  }
  data = {
    vault-token = data.vault_generic_secret.external_secrets_operator.data["VAULT_TOKEN"]
  }
  type = "Opaque"
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
