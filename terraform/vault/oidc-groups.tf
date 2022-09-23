resource "vault_identity_group" "developer" {
  name     = "developer"
  type     = "internal"
  policies = ["developer"]

  # `resource "vault_identity_group_member_entity_ids"` manages this in `developers.tf` 
  lifecycle {
    ignore_changes = [
      member_entity_ids
    ]
  }

  metadata = {
    version = "2"
  }
}

resource "vault_identity_group" "admin" {
  name     = "admin"
  type     = "internal"
  policies = ["admin"]

  # `resource "vault_identity_group_member_entity_ids"` manages this in `admins.tf` 
  lifecycle {
    ignore_changes = [
      member_entity_ids
    ]
  }

  metadata = {
    version = "2"
  }
}
