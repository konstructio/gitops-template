resource "vault_generic_secret" "clusters" {
  path = "secret/clusters/${var.cluster_name}"

  data_json = jsonencode(
    {
      kubeconfig              = azurerm_kubernetes_cluster.kubefirst.kube_config_raw
      host                    = azurerm_kubernetes_cluster.kubefirst.kube_config.0.host
      client_certificate      = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_certificate)
      client_key              = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.client_key)
      cluster_ca_certificate  = base64decode(azurerm_kubernetes_cluster.kubefirst.kube_config.0.cluster_ca_certificate)
      cluster_name            = var.cluster_name
      argocd_manager_sa_token = kubernetes_secret_v1.argocd_manager.data.token
    }
  )
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

# Used if using Azure DNS
data "vault_generic_secret" "azure_dns" {
  path = "secret/azure-dns"
}

# Used if using Cloudflare
data "vault_generic_secret" "external_dns" {
  path = "secret/external-dns"
}

resource "kubernetes_secret_v1" "external_dns" {
  metadata {
    name      = "external-dns-secrets"
    namespace = kubernetes_namespace_v1.external_dns.metadata.0.name
  }
  data = {
    "azure.json" = data.vault_generic_secret.azure_dns.data["azure.json"]
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
    mgmt_cluster_id = "<CLUSTER_ID>"
  }
}

