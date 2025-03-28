variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_count" {
  type = number
}

variable "node_type" {
  type = string
}

variable "is_gpu" {
  type    = bool
  default = false
}
