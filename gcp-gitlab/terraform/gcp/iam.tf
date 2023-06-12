module "argo_workflows" {
  source = "./modules/sa"

  service_account_name            = "argo-server-${local.cluster_name}"
  kubernetes_service_account_name = "argo-server"
  display_name                    = "Atlantis Service Account"
  project                         = var.project

  service_account_namespace = "argo"
  role                      = data.google_iam_role.owner.name
}

module "atlantis" {
  source = "./modules/sa"

  service_account_name            = "atlantis-${local.cluster_name}"
  kubernetes_service_account_name = "atlantis"
  display_name                    = "Atlantis Service Account"
  project                         = var.project

  service_account_namespace = "atlantis"
  role                      = data.google_iam_role.owner.name
}

module "cert_manager" {
  source = "./modules/sa"

  service_account_name            = "cert-manager-${local.cluster_name}"
  kubernetes_service_account_name = "cert-manager"
  display_name                    = "cert-manager Service Account"
  project                         = var.project

  service_account_namespace = "cert-manager"
  role                      = data.google_iam_role.dns_admin.name
}

module "chartmuseum" {
  source = "./modules/sa"

  service_account_name            = "chartmuseum-${local.cluster_name}"
  kubernetes_service_account_name = "chartmuseum"
  display_name                    = "Chart Museum Service Account"
  project                         = var.project

  service_account_namespace = "chartmuseum"
  role                      = data.google_iam_role.storage_admin.name
}

module "external_dns" {
  source = "./modules/sa"

  service_account_name            = "external-dns-${local.cluster_name}"
  kubernetes_service_account_name = "external-dns"
  display_name                    = "External DNS Service Account"
  project                         = var.project

  service_account_namespace = "external-dns"
  role                      = data.google_iam_role.dns_admin.name
}

module "vault" {
  source = "./modules/sa"

  service_account_name            = "vault-${local.cluster_name}"
  kubernetes_service_account_name = "vault"
  display_name                    = "Vault Service Account"
  project                         = var.project

  service_account_namespace = "vault"
  role                      = data.google_iam_role.dns_admin.name

  create_bucket_iam_access = true
  bucket_name              = module.vault_data_bucket.name

  create_service_account_key = true
  keyring                    = module.vault_keys.keyring
}
