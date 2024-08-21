module "metaphor" {
  source       = "./modules/project"
  group_name   = data.gitlab_group.owner.id
  project_name = "metaphor"
  # create_ecr                            = true
  initialize_with_readme                = false
  only_allow_merge_if_pipeline_succeeds = false
  remove_source_branch_after_merge      = true
}

module "gitops" {
  source       = "./modules/project"
  group_name   = data.gitlab_group.owner.id
  project_name = "gitops"
  # create_ecr                            = true
  initialize_with_readme                = false
  only_allow_merge_if_pipeline_succeeds = false
  remove_source_branch_after_merge      = true
}

resource "gitlab_project_hook" "atlantis" {
  project               = module.gitops.path
  url                   = var.atlantis_repo_webhook_url
  token                 = var.atlantis_repo_webhook_secret
  merge_requests_events = true
  push_events           = true
  note_events           = true
}
