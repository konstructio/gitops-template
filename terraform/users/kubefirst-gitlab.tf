terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}

data "gitlab_group" "kubefirst" {
  full_path = "kubefirst"
}
