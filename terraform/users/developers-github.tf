data "vault_identity_group" "developers_group" {
  group_name = "developers"
}

resource "vault_identity_group_member_entity_ids" "developers_membership" {
  member_entity_ids = [
    module.oernetes.vault_identity_entity_id
  ]

  # exclusive = true?

  group_id = data.vault_identity_group.developers_group.group_id
}

module "oernetes" {
  source = "./modules/user/github"

  acl_policies            = ["developer"]
  aws_secret_backend_path = data.vault_auth_backend.aws.accessor
  email                   = "oernetes@kubefirst.com"
  first_name              = "Oug"
  fullname                = "Oug Ernetes"
  github_username         = "kube1st"
  last_name               = "Ernetes"
  initial_password        = var.initial_password
  team_id                 = github_team.developers.id
  username                = "oernetes"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}