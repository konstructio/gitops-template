##################
# Storage Bucket #
##################

# Bucket
resource "google_storage_bucket" "bucket" {
  name = local.bucket_name

  uniform_bucket_level_access = var.uniform_bucket_policy

  dynamic "encryption" {
    for_each = var.kms_encryption_key
    content {
      default_kms_key_name = lookup(encryption.value, "key_name")
    }
  }

  force_destroy = var.force_destroy

  labels = merge(local.implicit_labels, var.bucket_labels)

  location = var.location

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        custom_time_before         = lookup(lifecycle_rule.value.condition, "custom_time_before", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
        matches_storage_class      = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        noncurrent_time_before     = lookup(lifecycle_rule.value.condition, "noncurrent_time_before", null)
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging_configuration
    content {
      log_bucket        = lookup(logging.value, "bucket")
      log_object_prefix = lookup(logging.value, "prefix")
    }
  }

  project = var.project

  storage_class = var.storage_class

  versioning {
    enabled = var.versioning_enabled
  }
}
