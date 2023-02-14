terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/users/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.20.0"
    }
  }
}

data "gitlab_group" "kubefirst" {
  full_path = "kubefirst"
}
