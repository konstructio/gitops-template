terraform {
  backend "s3" {
    bucket  = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key     = "terraform/github/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}



module "gitops" {
  source = "./modules/repository"

  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

resource "github_repository_webhook" "gitops_atlantis_webhook" {
    repository = module.gitops.repo_name
  
    configuration {
      url          = "<ATLANTIS_WEBHOOK_URL>"
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


module "metaphor" {
  source = "./modules/repository"

  repo_name          = "metaphor"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

module "metaphor_go" {
  source = "./modules/repository"

  repo_name          = "metaphor-go"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}

module "metaphor_frontend" {
  source = "./modules/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  create_ecr         = true
  team_developers_id = github_team.developers.id
  team_admins_id     = github_team.admins.id
}
