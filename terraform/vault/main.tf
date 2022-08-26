terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/vault/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
}

module "bootstrap" {
  source = "./bootstrap"

  aws_account_id       = var.aws_account_id
  aws_region           = var.aws_region
  vault_token          = var.vault_token
  email_address        = var.email_address
  vault_addr           = var.vault_addr
  hosted_zone_id       = var.hosted_zone_id
  hosted_zone_name     = var.hosted_zone_name
  gitlab_runner_token  = var.gitlab_runner_token
  gitlab_token         = var.gitlab_token
  git_provider         = var.git_provider
}

module "oidc" {
  source = "./oidc"

  vault_redirect_uris = var.vault_redirect_uris
}
