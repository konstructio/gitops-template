module "metaphor" {
  source       = "./modules/project"
  group_name   = data.gitlab_group.owner.id
  project_name = "metaphor"
  # create_ecr                            = true
  initialize_with_readme                = false
  only_allow_merge_if_pipeline_succeeds = false
  remove_source_branch_after_merge      = true
}

module "metaphor-go" {
  source       = "./modules/project"
  group_name   = data.gitlab_group.owner.id
  project_name = "metaphor-go"
  # create_ecr                            = true
  initialize_with_readme                = false
  only_allow_merge_if_pipeline_succeeds = false
  remove_source_branch_after_merge      = true
}

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
