provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = "kubefirst-tech-4"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "kubefirst-tech-4"
}

resource "vault_auth_backend" "k8s" {
  type = "kubernetes"
  path = "kubernetes/kubefirst"
}

// atlantis

data "kubernetes_service_account" "atlantis" {
  metadata {
    name      = "atlantis"
    namespace = "atlantis"
  }
}

data "kubernetes_secret" "atlantis_token_secret" {
  metadata {
    name      = data.kubernetes_service_account.atlantis.default_secret_name
    namespace = "atlantis"
  }
}

resource "vault_kubernetes_auth_backend_config" "vault_k8s_auth_atlantis" {
  backend            = vault_auth_backend.k8s.path
  kubernetes_host    = data.aws_eks_cluster.cluster.endpoint
  token_reviewer_jwt = data.kubernetes_secret.atlantis_token_secret.data.token
}

resource "vault_kubernetes_auth_backend_role" "k8s_atlantis" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "atlantis"
  bound_service_account_names      = ["atlantis"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["admin", "default"]
}

// external-secrets

data "kubernetes_service_account" "external_secrets" {
  metadata {
    name      = "external-secrets"
    namespace = "external-secrets-operator"
  }
}

data "kubernetes_secret" "external_secrets_token_secret" {
  metadata {
    name      = data.kubernetes_service_account.external_secrets.default_secret_name
    namespace = "external-secrets-operator"
  }
}

resource "vault_kubernetes_auth_backend_config" "vault_k8s_auth_es" {
  backend            = vault_auth_backend.k8s.path
  kubernetes_host    = data.aws_eks_cluster.cluster.endpoint
  token_reviewer_jwt = data.kubernetes_secret.external_secrets_token_secret.data.token
}

resource "vault_kubernetes_auth_backend_role" "k8s_external_secrets" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["admin", "default"]
}
