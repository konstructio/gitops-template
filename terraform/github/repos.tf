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


# module "example_repo" {
#   source = "./templates/repository"

#   repo_name          = "example-repo"
#   archive_on_destroy = false
#   auto_init          = false # set to false if importing an existing repository
#   team_engineers     = github_team.engineers.id
#   team_admins        = github_team.admins.id
# }
