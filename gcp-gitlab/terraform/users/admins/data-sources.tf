data "vault_identity_group" "admins" {
  group_name = "admins"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
