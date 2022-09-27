terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "terraform/github/tfstate.tf"
    region  = "<AWS_DEFAULT_REGION>"
    encrypt = true
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.26.0"
    }
  }
}

module "gitops" {
  source = "./templates/repository"

  repo_name          = "gitops"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

module "metaphor" {
  source = "./templates/repository"

  repo_name          = "metaphor"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

module "metaphor_go" {
  source = "./templates/repository"

  repo_name          = "metaphor-go"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}

module "metaphor_frontend" {
  source = "./templates/repository"

  repo_name          = "metaphor-frontend"
  archive_on_destroy = false
  auto_init          = false # set to false if importing an existing repository
  team_engineers     = github_team.engineers.id
  team_admins        = github_team.admins.id
}
