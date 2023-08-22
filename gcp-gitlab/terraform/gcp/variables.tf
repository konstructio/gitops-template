locals {
  cluster_name = "<CLUSTER_NAME>"
}

variable "gcp_region" {
  description = "GCP Cloud Region"
  type        = string

  default = "<CLOUD_REGION>"
}

variable "network_name" {
  description = "The name of the created network."
  type        = string

  default = "kubefirst"
}

variable "project" {
  description = "GCP Project ID"
  type        = string

  default = "<GCP_PROJECT>"
}

variable "force_destroy" {
  description = "variable used to control bucket force destroy"
  type        = bool

  default = "false"
}
