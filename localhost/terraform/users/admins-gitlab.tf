data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_member_entity_ids" "admin_membership" {
  member_entity_ids = [
    module.kubefirst_bot.vault_identity_entity_id
  ]

  group_id = data.vault_identity_group.admins.group_id
}

variable "initial_password" {
  type    = string
  default = ""
}

module "kubefirst_bot" {
  source = "./modules/user/gitlab"

  acl_policies      = ["admin"]
  email             = "<EMAIL_ADDRESS>"
  first_name        = "Kubefirst"
  fullname          = "Kubefirst Bot"
  group_id          = data.vault_identity_group.admins.group_id
  last_name         = "Bot"
  initial_password  = var.initial_password
  username          = "kbot"
  user_disabled     = false
  userpass_accessor = data.vault_auth_backend.userpass.accessor
}

# module "admin_one" {
#   source = "./modules/user/github"

#   acl_policies            = ["admin"]
#   email                   = "admin@your-company-io.com"
#   first_name              = "Admin"
#   fullname                = "Admin One"
#   group_id                = data.vault_identity_group.admins.group_id
#   last_name               = "One"
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
