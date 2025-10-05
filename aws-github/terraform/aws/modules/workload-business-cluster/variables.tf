variable "cluster_name" {
  description = "the name of the cluster"
  type        = string
}

variable "cluster_region" {
  description = "the region of the cluster"
  type        = string
}

variable "node_count" {
  description = "The node count for the node group"
  default     = "2"
  type        = string
}

variable "node_type" {
  description = "The node type of node group"
  default     = "t3.medium"
  type        = string
}

variable "ami_type" {
  description = "the ami type for node group"
  default = "AL2_x86_64"
  type = string
}

variable "account_id" {
  description = "the account id where the cluster is being created"
  type        = string
}


variable s3_bucket_name {
  description = "the name of the s3 bucket to store terraform state"
  type        = string
}
