variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
}

variable "google_region" {
  description = "Google Region"
  type        = string
}

variable "instance_type" {
  description = "Instance type to use on cluster Nodes."
  type        = string

  default = "e2-medium"
}

variable "network" {
  description = "The network to use with the cluster."
  type        = string
}

variable "project" {
  description = "Google Project ID"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to use with the cluster."
  type        = string
}
