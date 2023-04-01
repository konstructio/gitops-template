data "github_team" "developers" {
  slug = "developers"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
