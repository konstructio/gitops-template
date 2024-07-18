data "github_team" "developers" {
  slug = "<DEVELOPER-TEAM>"
}

data "vault_auth_backend" "userpass" {
  path = "userpass"
}
