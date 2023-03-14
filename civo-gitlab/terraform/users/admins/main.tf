data "vault_identity_group" "admins" {
  group_name = "admins"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}

variable "initial_password" {
  type    = string
  default = ""
}

resource "vault_identity_group_member_entity_ids" "admin_membership" {
  member_entity_ids = [
    module.kbot.vault_identity_entity_ids,
    # TODO: add admins to this list as you add them to the platform to give them SSO access
  ]
  group_id = data.vault_identity_group.admins.group_id
}
