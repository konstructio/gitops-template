data "vault_auth_backend" "userpass" {
  path = "userpass"
}

data "vault_auth_backend" "aws" {
  path = "aws"
}
