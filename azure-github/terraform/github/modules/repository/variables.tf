variable "archive_on_destroy" {
  type    = bool
  default = true
}

variable "auto_init" {
  type    = string
  default = true
}

variable "default_branch_name" {
  type    = string
  default = "main"
}

variable "create_ecr" {
  type    = bool
  default = false
}

variable "delete_branch_on_merge" {
  type    = bool
  default = true
}

variable "description" {
  type    = string
  default = ""
}

variable "homepage_url" {
  type    = string
  default = ""
}

variable "is_template" {
  type    = bool
  default = false
}

variable "template" {
  type        = map(string)
  description = "Template Repository object for Repository creation"
  default     = {}
}

variable "pages" {
  type        = map(any)
  description = "Configuration block for GitHub Pages"
  default     = {}
}

variable "repo_name" {
  type = string
}

variable "visibility" {
  type    = string
  default = "private"
}

variable "team_developers_id" {
  type = string
}
variable "team_admins_id" {
  type = string
}

variable "topics" {
  type    = list(string)
  default = []
}

variable "has_downloads" {
  type    = bool
  default = false
}
variable "has_issues" {
  type    = bool
  default = true
}
variable "has_projects" {
  type    = bool
  default = false
}
variable "has_wiki" {
  type    = bool
  default = false
}
variable "vulnerability_alerts" {
  type    = bool
  default = false
}
