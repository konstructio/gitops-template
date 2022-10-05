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

module "kubefirst_bot" {
  source = "./modules/user/gitlab"

  acl_policies            = ["admin"]
  aws_secret_backend_path = data.vault_auth_backend.aws.accessor
  email                   = "<EMAIL_ADDRESS>"
  first_name              = "Kubefirst"
  fullname                = "Kubefirst Bot"
  group_id                = data.vault_identity_group.admins.group_id
  last_name               = "Bot"
  initial_password        = var.initial_password
  username                = "kbot"
  user_disabled           = false
  userpass_accessor       = data.vault_auth_backend.userpass.accessor
}

# TODO: add your additional admins like the kubefirst_bot module is above, but with their information

variable "initial_password" {
  type    = string
  default = ""
}
