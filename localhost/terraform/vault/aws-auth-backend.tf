resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}

resource "vault_auth_backend" "aws" {
  type = "aws"
  path = "aws"
}
