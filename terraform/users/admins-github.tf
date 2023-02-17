data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_member_entity_ids" "admins_membership" {
  member_entity_ids = [
    module.kbot.vault_identity_entity_id
#    , module.admin_one.vault_identity_entity_id
  ]

  group_id = data.vault_identity_group.admins.group_id
}

variable "initial_password" {
  type    = string
  default = ""
}

module "kbot" {
  source = "./modules/user/github"

  acl_policies      = ["admin"]
  email             = "<EMAIL_ADDRESS>"
  first_name        = "K"
  github_username   = "<GITHUB_USER>"
  last_name         = "Bot"
  initial_password  = var.initial_password
  team_id           = data.github_team.admins.id
  username          = "kbot"
  user_disabled     = false
  userpass_accessor = data.vault_auth_backend.userpass.accessor
}
  
# # note: when you uncomment and change admin_one below 
# # to your admin's firstname_lastname, you must also uncomment 
# # and change the "admins_membership" list above to match your
# # individual's firstname_lastname. create as many admin modules
# # as you have admin personnel.
  
# module "admin_one" {
#   source = "./modules/user/github"

#   acl_policies            = ["admin"]
#   email                   = "your.admin@your-company.io"
#   first_name              = "Admin"
#   github_username         = "admin_one_github_username"
#   last_name               = "One"
#   team_id                 = data.github_team.admins.id
#   username                = "aone"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
