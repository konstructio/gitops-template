variable "repository_name" {
  type = string
}

variable "use_ecr" {
  type        = bool
  default     = false
  description = "boolean that changes if we create ecr resources"
}