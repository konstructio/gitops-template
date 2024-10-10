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

variable "cluster_type" {
  type        = string
  description = "type of cluster talos/k3s"
}

variable "labels" {
  type = map(string)
}

variable "mgmt_cluster_id" {
  type = string
}