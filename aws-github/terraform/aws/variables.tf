variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "instance_type" {
  description = "The instance type of node group"
  default     = "t3.medium"
  type        = string
}

variable "ami_type" {
  description = "The chipset of nodes"
  default     = "AL2_x86_64"
  type        = string
}

variable "use_ecr" {
  type        = bool
  default     = false
  description = "boolean that changes if we create ecr resources"
}