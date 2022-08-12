variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "lifecycle_nodes" {
  description = "The lifecycle of a node, can be SPOT or ON_DEMAND"
  default = "ON_DEMAND"
  type = string
}
