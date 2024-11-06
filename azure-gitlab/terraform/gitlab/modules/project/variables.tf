variable "archived" {
  description = "whether to archive the repo (make it readonly)"
  type        = bool
  default     = false
}

variable "create_deploy_key" {
  description = "whether or not to create a deploy key for ci to commit to the repo"
  type        = bool
  default     = false
}

variable "default_branch" {
  description = "specifies what the default branch is for the repository"
  type        = string
  default     = "main"
}

variable "group_name" {
  description = "the group name the repository belongs to"
  type        = string
}

variable "import_url" {
  description = "import url of the git repository"
  type        = string
  default     = null
}
variable "initialize_with_readme" {
  description = "whether or not to add a readme at project creation"
  type        = bool
  default     = true
}

variable "only_allow_merge_if_pipeline_succeeds" {
  description = "set to true once your branch or mr has a successful pipeline you can depend on"
  type        = bool
}

variable "project_name" {
  description = "the name of the project"
  type        = string
}

variable "remove_source_branch_after_merge" {
  description = "whether or not we should remove source branch after a merge"
  type        = bool
}
