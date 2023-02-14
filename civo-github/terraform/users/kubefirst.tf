terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/users/tfstate.tf"
    endpoint = "https://objectstore.<CLOUD_REGION>.civo.com"

    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
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
