data "vault_identity_group" "admins" {
  group_name = "admins"
}

data "vault_identity_group" "developers" {
  group_name = "developers"
}

resource "vault_identity_oidc_assignment" "app" {
  name      = var.app_name
  group_ids = [data.vault_identity_group.admins.group_id, data.vault_identity_group.developers.group_id]
}

resource "vault_identity_oidc_client" "app" {
  name          = var.app_name
  key           = var.oidc_provider_key_name
  redirect_uris = var.redirect_uris
  assignments = [
    vault_identity_oidc_assignment.app.name,
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
  client_type      = "confidential"
}

output "vault_oidc_app_name" {
  value = vault_identity_oidc_client.app.name
}

variable "app_name" {
  type = string
}

variable "oidc_provider_key_name" {
  type = string
}

variable "redirect_uris" {
  type = list(string)
}

variable "secret_mount_path" {
  type = string
}

data "vault_identity_oidc_client_creds" "creds" {
  name = var.app_name

  depends_on = [
    vault_identity_oidc_client.app
  ]

}

resource "vault_generic_secret" "creds" {
  path = "${var.secret_mount_path}/oidc/${var.app_name}"

  depends_on = [
    vault_identity_oidc_client.app
  ]

  data_json = <<EOT
{
  "client_id" : "${data.vault_identity_oidc_client_creds.creds.client_id}",
  "client_secret" : "${data.vault_identity_oidc_client_creds.creds.client_secret}"
}
EOT
}
