data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_member_entity_ids" "admins_membership" {
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
  source = "./modules/user/github"

  acl_policies            = ["admin"]
  email                   = "k-ray@example.com"
  first_name              = "Kubefirst"
  github_username         = "<GITHUB_USER>"
  last_name               = "Bot"
  team_id                 = data.github_team.admins.id
  initial_password        = var.initial_password
  username                = "kbot"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}

# module "admin_one" {
#   source = "./modules/user/github"

#   acl_policies            = ["admin"]
#   email                   = "admin@your-company-io.com"
#   first_name              = "Admin"
#   github_username         = "admin_one_github_username"
#   last_name               = "One"
#   team_id                 = data.github_team.admins.id
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
