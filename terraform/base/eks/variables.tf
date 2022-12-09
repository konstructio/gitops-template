variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)

  default = []
}
variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "cluster_name" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "lifecycle_nodes" {
  description = "The lifecycle of a node, can be SPOT or ON_DEMAND"
  default = "<AWS_LIFECYCLE_NODES>"
  type = string
}

variable "instance_type" {
  description = "The instance type of node group"
  default = "t3.medium"
  type = string
}

variable "ami_type" {
  description = "The chipset of nodes"
  default = "AL2_x86_64"
  type = string
}
