data "vault_identity_group" "developers" {
  group_name = "developers"
}

resource "vault_identity_group_member_entity_ids" "developer_membership" {
 member_entity_ids = [
    # TODO: add developers to this list as you add them to the platform to give them SSO access
    # module.developer_one.vault_identity_entity_id,
 ]

 group_id = data.vault_identity_group.developers.group_id
}
