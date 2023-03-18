terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "15.8.0"
    }
  }
}

resource "aws_ecr_repository" "repo" {
  count                = var.create_ecr != true ? 0 : 1
  name                 = "<ECR_REPOSITORY_NAME>"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "gitlab_project" "project" {
  name                   = var.project_name
  archived               = var.archived
  visibility_level       = "private"
  default_branch         = var.default_branch
  namespace_id           = var.group_name
  import_url             = var.import_url
  initialize_with_readme = var.initialize_with_readme
  shared_runners_enabled = false
  # https://docs.gitlab.com/ee/user/packages/container_registry/
  only_allow_merge_if_all_discussions_are_resolved = true
  only_allow_merge_if_pipeline_succeeds            = var.only_allow_merge_if_pipeline_succeeds
  remove_source_branch_after_merge                 = var.remove_source_branch_after_merge
}
