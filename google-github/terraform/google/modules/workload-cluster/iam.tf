module "cert_manager" {
  source = "./sa"

  service_account_name            = "cert-manager-${var.cluster_name}"
  kubernetes_service_account_name = "cert-manager"
  display_name                    = "cert-manager Service Account"
  project                         = var.project

  service_account_namespace = "cert-manager"
  role                      = data.google_iam_role.dns_admin.name
}

module "external_dns" {
  source = "./sa"

  service_account_name            = "external-dns-${var.cluster_name}"
  kubernetes_service_account_name = "external-dns"
  display_name                    = "External DNS Service Account"
  project                         = var.project

  service_account_namespace = "external-dns"
  role                      = data.google_iam_role.dns_admin.name
}
