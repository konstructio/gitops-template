terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.20.0"
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

variable "acl_policies" {
  type = list(string)
}

variable "username" {
  type        = string
  description = "a distinct username that is unique to this user throughout the kubefirst ecosystem"
}

variable "user_disabled" {
  type = string
}

variable "first_name" {
  type = string
}

variable "last_name" {
  type = string
}

variable "fullname" {
  type        = string
  description = "example: Jane Doe"
}

variable "userpass_accessor" {
  type = string
}

variable "initial_password" {
  type    = string
  default = ""
}

variable "email" {
  type        = string
  description = "jane.doe@your-domain.io"
}

variable "enabled" {
  default     = true
  description = "setting to false allows you to destroy all resources so you can cleanly remove the user before removing them from terraform"
}
variable "group_id" {
  type        = string
  description = "the group assignment for the user"
}

data "vault_identity_group" "admins" {
  group_name = "admins"
}

data "gitlab_group" "admins" {
  full_path = "admins"
}

data "gitlab_group" "developers" {
  full_path = "developers"
}

resource "gitlab_user" "user" {
  count            = var.enabled ? 1 : 0
  name             = var.fullname
  username         = var.username
  password         = var.initial_password == "" ? random_password.password.result : var.initial_password
  email            = var.email
  is_admin         = var.group_id == data.vault_identity_group.admins.group_id ? true : false
  projects_limit   = 100
  can_create_group = true
  is_external      = false
  reset_password   = false
  # initial gitlab password are stored in vault. to allow gitlab to manage passwords,
  # you should remove `password` and change `reset_password` to true. however, you'll need to
  # enable gitlab email before setting to reset_password to true. see this link for config settings:
  # https://github.com/gitlabhq/omnibus-gitlab/blob/master/doc/settings/smtp.md
  # we didn't want this dependency on kubefirst's initial setup due to the variations in how companies
  # manage email. if you don't have company email available to you, the gmail integration works well.
}

resource "gitlab_group_membership" "user_admin_group" {
  count        = var.enabled ? 1 : 0
  group_id     = var.group_id == data.vault_identity_group.admins.group_id ? data.gitlab_group.admins.id : data.gitlab_group.developers.id
  user_id      = gitlab_user.user[count.index].id
  access_level = var.group_id == data.vault_identity_group.admins.group_id ? "owner" : "maintainer"
}
