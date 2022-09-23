terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

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
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true

  data_json = jsonencode(
    {
      policies  = var.acl_policies,
      password  = random_password.password.result
      token_ttl = "1h"
    }
  )
}

resource "vault_generic_secret" "user" {
  path = "users/${var.username}"

  data_json = <<EOT
{
  "initial-password": "${random_password.password.result}"
}
EOT
}

resource "aws_iam_user" "user" {
  name = var.username
  path = "/"

  tags = {
    ManagedBy = "terraform"
  }
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

variable "aws_secret_backend_path" {
  type = string
}

variable "github_username" {
  type = string
}

variable "role" {
  type = string
}

variable "email" {
  type = string
}

variable "team_id" {
  description = "the github team id to place the user"
}

resource "github_team_membership" "admins_team_membership" {
  team_id  = var.team_id
  username = var.github_username
  role     = var.role
}
