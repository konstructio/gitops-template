resource "vault_identity_entity" "user" {
  name     = var.username
  disabled = var.user_disabled
  metadata = {
    email      = var.email
    first_name = var.first_name
    last_name  = var.last_name
  }
}

output "vault_identity_entity_id" {
  value = vault_identity_entity.user.id
}

resource "vault_identity_entity_alias" "user" {
  name           = var.username
  mount_accessor = var.userpass_accessor
  canonical_id   = vault_identity_entity.user.id
}

resource "random_password" "password" {
  length           = 25
  special          = true
  override_special = "!#$@"
}

resource "vault_generic_endpoint" "user" {
  depends_on           = [vault_generic_endpoint.user_password] # avoids race condition
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true

  data_json = jsonencode(
    {
      policies  = var.acl_policies,
      token_ttl = "1h"
    }
  )
}

resource "vault_generic_endpoint" "user_password" {
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true
  lifecycle {
    ignore_changes = [data_json]
  }

  # note: this resource includes the initial password and only gets applied once
  # changes to the user should be managed by the vault_generic_endpoint named "user" above
  data_json = jsonencode(
    {
      password  = var.initial_password != "" ? var.initial_password : random_password.password.result,
      policies  = var.acl_policies,
      token_ttl = "1h"
    }
  )
}

resource "vault_generic_secret" "user" {
  path = "users/${var.username}"

  data_json = <<EOT
{
  "initial-password": "${var.initial_password != "" ? var.initial_password : random_password.password.result}"
}
EOT
}

variable "acl_policies" {
  type = list(string)
}

variable "username" {
  type        = string
  description = "a distinct username that is unique to this user throughout the kubefirst ecosystem"
}

variable "user_disabled" {
  type    = bool
  default = false
}

variable "userpass_accessor" {
  type = string
}

variable "github_username" {
  type = string
}

variable "email" {
  type = string
}

variable "first_name" {
  type = string
}

variable "last_name" {
  type = string
}

variable "initial_password" {
  type    = string
  default = ""
}

variable "team_id" {
  description = "the github team id to place the user"
}

resource "github_team_membership" "team_membership" {
  count    = var.user_disabled == true ? 0 : 1
  team_id  = var.team_id
  username = var.github_username
}
