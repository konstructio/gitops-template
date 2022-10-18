terraform {
  backend "s3" {
    bucket = "kubefirst-state-store"
    key     = "terraform/github/tfstate.tf"
    endpoint = "http://127.0.0.1:9000"

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
      source  = "integrations/github"
      version = "4.26.0"
    }
  }
}

module "gitops" {
  source = "./modules/repository"
  visibility = "public"
  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
  
}

resource "github_repository_webhook" "gitops_atlantis_webhook" {
    repository = module.gitops.repo_name
  
    configuration {
      #TODO:jedwards  We need to change this to be an ngrok route!!!
      url          = "https://atlantis.<AWS_HOSTED_ZONE_NAME>/events"
      content_type = "json"
      insecure_ssl = false
      secret       = var.atlantis_repo_webhook_secret
    }
  
    active = true
  
    events = ["pull_request_review", "push", "issue_comment", "pull_request"]
}
variable "atlantis_repo_webhook_secret" {
  type = string
  default = ""
}
