data "github_team" "admins" {
  slug = "<ADMIN-TEAM>"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
