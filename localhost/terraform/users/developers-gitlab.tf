data "vault_identity_group" "developers" {
  group_name = "developers"
}

# resource "vault_identity_group_member_entity_ids" "developer_membership" {
#  member_entity_ids = [
#    module.developer_one.vault_identity_entity_id
#  ]

#  group_id = data.vault_identity_group.developers.group_id
# }

# module "developer_one" {
#   source = "./modules/user/gitlab"
# 
#   acl_policies            = ["developer"]
#   email                   = "dev.one@example.com"
#   first_name              = "Dev"
#   fullname                = "Dev One"
#   group_id                = data.vault_identity_group.developers.group_id
#   last_name               = "One"
#   team_id                 = data.github_team.developers.id
#   username                = "done"
#   user_disabled           = false
#   userpass_accessor       = data.vault_auth_backend.userpass.accessor
# }
