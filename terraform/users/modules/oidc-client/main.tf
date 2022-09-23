data "vault_identity_group" "admin" {
  group_name = "admin"
}

data "vault_identity_group" "developer" {
  group_name = "developer"
}

resource "vault_identity_oidc_assignment" "app" {
  name      = var.app_name
  group_ids = [data.vault_identity_group.admin.group_id, data.vault_identity_group.developer.group_id]
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

variable "app_name" {
  type = string
}

variable "oidc_provider_key_name" {
  type = string
}

variable "redirect_uris" {
  type = list(string)
}
