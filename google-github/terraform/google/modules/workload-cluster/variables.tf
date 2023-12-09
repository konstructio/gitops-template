variable "cluster_name" {
  description = "cluster name"
  type        = string

  default = "<CLUSTER_NAME>"
}

variable "environment" {
  description = "environment for the clusters"
  type        = string

  default = "<CLUSTER_NAME>"
}

variable "google_region" {
  description = "Google Cloud Region"
  type        = string

  default = "<CLOUD_REGION>"
}

variable "network_name" {
  description = "The name of the created network."
  type        = string

  default = "<CLUSTER_NAME>"
}

variable "node_count" {
  description = "The node count per zone for the cluster."
  type        = string

  default = "<NODE_COUNT>"
}

variable "project" {
  description = "Google Project ID"
  type        = string

  default = "<GOOGLE_PROJECT>"
}

variable "force_destroy" {
  description = "variable used to control bucket force destroy"
  type        = bool

  default = "false"
}

