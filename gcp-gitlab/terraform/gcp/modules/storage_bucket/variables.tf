locals {
  bucket_name    = "${var.project}-${var.bucket_name}"
  logging_prefix = "${local.bucket_name}/"

  implicit_labels = {
    name    = local.bucket_name
    project = var.project
  }
}

variable "project" {
  description = "GCP Project ID"
  type        = string
}


variable "bucket_labels" {
  description = "A set of key/value label pairs to assign to the bucket."

  type    = map(string)
  default = {}
}

variable "bucket_name" {
  description = "The name for the bucket."

  type    = string
  default = ""
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If you try to delete a bucket that contains objects, Terraform will fail that run."

  type    = bool
  default = false
}

# https://cloud.google.com/storage/docs/encryption/using-customer-managed-keys
variable "kms_encryption_key" {
  description = "A Cloud KMS key that will be used to encrypt objects inserted into this bucket. Must be a single item list containing the name of the key."

  type    = list(any)
  default = []
}

# https://cloud.google.com/storage/docs/lifecycle
variable "lifecycle_rules" {
  description = "The bucket's lifecycle rules configuration."
  type = list(object({
    action    = any
    condition = any
  }))
  default = []
}

# https://cloud.google.com/storage/docs/bucket-locations
variable "location" {
  description = "The GCS location."

  type    = string
  default = "us"
}

# https://cloud.google.com/storage/docs/access-logs
variable "logging_configuration" {
  description = "The bucket's Access & Storage Logs configuration."

  type    = list(string)
  default = []
}

variable "name_override" {
  description = "Override automatic bucket name creation. This will result in the name format project-name_override."

  type    = string
  default = ""
}

# https://cloud.google.com/storage/docs/storage-classes
variable "storage_class" {
  description = "The Storage Class of the new bucket. Supported values include: STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."

  type    = string
  default = "STANDARD"
}

# https://cloud.google.com/storage/docs/access-control/?_ga=2.144606653.-922453139.1594828062
variable "uniform_bucket_policy" {
  description = "Whether to enforce uniform access on the bucket. This applies to all objects and removes fine grained control."

  type    = bool
  default = true
}

variable "versioning_enabled" {
  description = "Whether or not to enable versioning for the bucket."

  type    = bool
  default = true
}
