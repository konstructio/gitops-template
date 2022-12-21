variable "aws_account_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "ami_type" {
  description = "The chipset of nodes"
  default = "AL2_x86_64"
  type = string
}

variable "instance_type" {
  description = "The instance type of node group"
  default = "t3.medium"
  type = string
}

variable "lifecycle_nodes" {
  description = "The lifecycle of a node, can be SPOT or ON_DEMAND"
  default = "<AWS_LIFECYCLE_NODES>"
  type = string
}
