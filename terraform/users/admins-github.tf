data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_member_entity_ids" "admins_membership" {
  member_entity_ids = [
    module.kubefirst_bot.vault_identity_entity_id
  ]

  # exclusive = true?

  group_id = data.vault_identity_group.admins.group_id
}

module "kubefirst_bot" {
  source = "./modules/user/github"

  acl_policies            = ["admin"]
  aws_secret_backend_path = data.vault_auth_backend.aws.accessor
  email                   = "<EMAIL_ADDRESS>"
  first_name              = "Kubefirst"
  fullname                = "Kubefirst Bot"
  github_username         = "<GITHUB_USER>"
  last_name               = "Bot"
  initial_password        = var.initial_password
  team_id                 = data.github_team.admins.id
  username                = "kbot"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}

variable "initial_password" {
  type    = string
  default = ""
}
