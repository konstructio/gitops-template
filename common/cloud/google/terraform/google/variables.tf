locals {
  cluster_name = "<CLUSTER_NAME>"
}

variable "google_region" {
  description = "Google Cloud Region"
  type        = string

  default = "<CLOUD_REGION>"
}

variable "network_name" {
  description = "The name of the created network."
  type        = string

  default = "kubefirst"
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

variable "uniqueness" {
  description = "variable used to avoid collision amongst immutable resource names"
  type        = string
}
