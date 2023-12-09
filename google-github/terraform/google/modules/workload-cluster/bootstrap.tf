data "google_client_config" "provider" {}

data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  project  = var.project
  location = "us-central1"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
  )
}

resource "vault_generic_secret" "clusters" {
  path = "secret/clusters/${var.cluster_name}"

  data_json = jsonencode(
    {
      kubeconfig              = "not sure if this is used yet."
      token                   = data.google_client_config.provider.access_token
      cluster_ca_certificate  = base64decode(data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate)
      host                    = data.google_container_cluster.cluster.endpoint
      cluster_name            = var.cluster_name
      environment             = var.environment
      argocd_manager_sa_token = kubernetes_secret_v1.argocd_manager.data.token
    }
  )
  depends_on = [ module.gke ]
}


resource "kubernetes_cluster_role_v1" "argocd_manager" {
  metadata {
    name = "argocd-manager-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}


resource "kubernetes_cluster_role_binding_v1" "argocd_manager" {
  metadata {
    name = "argocd-manager-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.argocd_manager.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd_manager.metadata.0.name
    namespace = "kube-system"
  }
}

resource "kubernetes_service_account_v1" "argocd_manager" {
  metadata {
    name      = "argocd-manager"
    namespace = "kube-system"
  }
  secret {
    name = "argocd-manager-token"
  }
}

resource "kubernetes_secret_v1" "argocd_manager" {
  metadata {
    name      = "argocd-manager-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = "argocd-manager"
    }
  }
  type       = "kubernetes.io/service-account-token"
  depends_on = [kubernetes_service_account_v1.argocd_manager]
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
    mgmt_cluster_id = "p8x68h"
  }
}
