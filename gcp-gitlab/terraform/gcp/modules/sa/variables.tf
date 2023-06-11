variable "service_account_name" {
  description = "The name of the service account."
  type        = string
}

variable "display_name" {
  description = "Display name (description) for the service account."
  type        = string
}

variable "project" {
  description = "GCP Project ID"
  type        = string
}


variable "service_account_namespace" {
  description = "The Kubernetes Namespace for the role."
  type        = string
}

variable "role" {
  description = "IAM role to assign to the service account."
  type        = string
}

variable "create_service_account_key" {
  description = ""
  type        = bool

  default = false
}

variable "keyring" {
  description = ""
  type        = string

  default = ""
}

variable "create_bucket_iam_access" {
  description = ""
  type        = bool

  default = false
}

variable "bucket_name" {
  description = ""
  type        = string

  default = ""
}
