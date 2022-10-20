terraform {
  backend "s3" {
    bucket = "kubefirst-state-store"
    key     = "terraform/users/tfstate.tf"
    endpoint = "http://minio.minio.svc.cluster.local:9000"

    access_key="k-ray"
    secret_key="feedkraystars"
    region = "us-k3d-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
  required_providers {
    github = {
      source = "integrations/github"
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
