module "vault_data_bucket" {
  source = "./modules/storage_bucket"

  bucket_name   = "<VAULT_DATA_BUCKET>"
  force_destroy = var.force_destroy
  # https://cloud.google.com/storage/docs/locations#location-dr
  # https://cloud.google.com/storage/docs/key-terms#geo-redundant
  # Dual-Region buckets are geo redundant.
  location           = "nam4"
  project            = var.project
  versioning_enabled = true
}
