###########
# Outputs #
###########

output "name" {
  value       = join("", google_storage_bucket.bucket.*.name)
  description = "The name of bucket."
}

output "self_link" {
  value       = join("", google_storage_bucket.bucket.*.self_link)
  description = "The URI of the created bucket resource."
}

output "url" {
  value       = join("", google_storage_bucket.bucket.*.url)
  description = "The base URL of the bucket, in the format: gs://<bucket-name>"
}
