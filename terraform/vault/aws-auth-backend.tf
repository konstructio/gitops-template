resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}

resource "vault_auth_backend" "aws" {
  type = "aws"
  path = "aws"
}

resource "vault_aws_secret_backend" "aws" {}

resource "vault_aws_secret_backend_role" "admin" {
  backend         = vault_auth_backend.aws.path
  name            = "KubernetesAdmin"
  credential_type = "assumed_role"

  role_arns = ["arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin"]
}

resource "vault_aws_secret_backend_role" "developer" {
  backend         = vault_auth_backend.aws.path
  name            = "KubernetesDeveloper"
  credential_type = "assumed_role"

  role_arns = ["arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesDeveloper"]
}
