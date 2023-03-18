data "github_team" "admins" {
  slug = "admins"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
