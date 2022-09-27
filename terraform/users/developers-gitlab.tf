data "vault_identity_group" "developer_group" {
  group_name = "developer"
}

resource "vault_identity_group_member_entity_ids" "developer_membership" {
  member_entity_ids = [
    module.qernetes.vault_identity_entity_id
  ]
  # exclusive = true?

  group_id = data.vault_identity_group.developer_group.group_id
}

module "qernetes" {
  source = "./modules/user/gitlab"

  acl_policies            = ["developer"]
  aws_secret_backend_path = data.vault_auth_backend.aws.accessor
  email                   = "qernetes@kubefirst.com"
  first_name              = "Qoug"
  fullname                = "Qoug Ernetes"
  group_id                = data.vault_identity_group.developer_group.group_id
  last_name               = "Ernetes"
  username                = "qernetes"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}
