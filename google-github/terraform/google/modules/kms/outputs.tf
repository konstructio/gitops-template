###########
# Outputs #
###########

output "keyring" {
  value = google_kms_key_ring.key_ring.id
}

output "keyring_resource" {
  value = google_kms_key_ring.key_ring
}

output "keys" {
  value = local.keys_by_name
}

output "keyring_name" {
  value = google_kms_key_ring.key_ring.name
}
