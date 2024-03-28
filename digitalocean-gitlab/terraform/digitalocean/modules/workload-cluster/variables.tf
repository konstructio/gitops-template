variable "cluster_name" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "environment" {
  type    = string
  default = ""
}

variable "node_type" {
  type = string
}

variable "node_count" {
  type = number
}
