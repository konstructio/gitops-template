data "github_team" "admins" {
  slug = "<ADMIN_TEAM>"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
