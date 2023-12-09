variable "cluster_name" {
  description = "cluster name"
  type        = string
}

variable "environment" {
  description = "environment for the clusters"
  type        = string
}

variable "google_region" {
  description = "Google Cloud Region"
  type        = string
}

variable "network_name" {
  description = "The name of the created network."
  type        = string
}

variable "node_count" {
  description = "The node count per zone for the cluster."
  type        = string
}

variable "project" {
  description = "Google Project ID"
  type        = string
}

variable "force_destroy" {
  description = "variable used to control bucket force destroy"
  type        = bool

  default = "false"
}

