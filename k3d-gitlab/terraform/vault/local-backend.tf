terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "17.1.0"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
}
