data "vault_identity_group" "admins" {
  group_name = "admins"
}

resource "vault_identity_group_member_entity_ids" "admin_membership" {
  member_entity_ids = [
    module.zernetes.vault_identity_entity_id
  ]

  # exclusive = true?

  group_id = data.vault_identity_group.admins.group_id
}

module "zernetes" {
  source = "./modules/user/gitlab"

  acl_policies            = ["admin"]
  aws_secret_backend_path = data.vault_auth_backend.aws.accessor
  email                   = "zernetes@kubefirst.com"
  first_name              = "Zoug"
  fullname                = "Zoug Ernetes"
  group_id                = data.vault_identity_group.admins.group_id
  last_name               = "Ernetes"
  initial_password        = var.initial_password
  username                = "zernetes"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}

variable "initial_password" {
  type    = string
  default = ""
}
