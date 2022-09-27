terraform {
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
