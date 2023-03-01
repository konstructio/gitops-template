provider "kubernetes" {
  config_path = "<KUBE_CONFIG_PATH>"
}

data "civo_kubernetes_cluster" "kubefirst" {
  name = local.cluster_name
}

resource "vault_auth_backend" "k8s" {
  type = "kubernetes"
  path = "kubernetes/kubefirst"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.k8s.path
  kubernetes_host = data.civo_kubernetes_cluster.kubefirst.api_endpoint
}

resource "vault_kubernetes_auth_backend_role" "k8s_atlantis" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "atlantis"
  bound_service_account_names      = ["atlantis"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["admin", "default"]
}

resource "vault_kubernetes_auth_backend_role" "k8s_external_secrets" {
  backend                          = vault_auth_backend.k8s.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["admin", "default"]
}
