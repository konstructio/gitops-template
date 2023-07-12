data "google_client_config" "default" {}

data "google_container_cluster" "this" {
  name     = "<CLUSTER_NAME>"
  location = "<CLOUD_REGION>"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth)
}

resource "vault_auth_backend" "k8s" {
  type = "kubernetes"
  path = "kubernetes/kubefirst"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://${data.google_container_cluster.this.endpoint}"
}

resource "vault_kubernetes_auth_backend_config" "vault_k8s_auth_es" {
  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://${data.google_container_cluster.this.endpoint}"
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
