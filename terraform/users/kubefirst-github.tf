
terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/users/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.3.0"
    }
  }
}

data "github_team" "admins" {
  slug = "admins"
}

data "github_team" "developers" {
  slug = "developers"
}
