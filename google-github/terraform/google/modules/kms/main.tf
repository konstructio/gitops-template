################
# KMS Key Ring #
################

# A key ring must exist for subsequent keys to be created and stored in.
resource "google_kms_key_ring" "key_ring" {
  name = var.keyring

  project  = var.project
  location = var.location
}

# Keys

resource "google_kms_crypto_key" "key" {
  count = length(var.keys)

  name = var.keys[count.index]

  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.key_rotation_period
}

resource "google_kms_crypto_key_iam_binding" "owners" {
  count = length(var.set_owners_for)

  role          = "roles/owner"
  crypto_key_id = local.keys_by_name[var.set_owners_for[count.index]]
  members       = compact(split(",", var.owners[count.index]))
}

resource "google_kms_crypto_key_iam_binding" "decrypters" {
  count = length(var.set_decrypters_for)

  role          = "roles/cloudkms.cryptoKeyDecrypter"
  crypto_key_id = local.keys_by_name[var.set_decrypters_for[count.index]]
  members       = compact(split(",", var.decrypters[count.index]))
}

resource "google_kms_crypto_key_iam_binding" "encrypters" {
  count = length(var.set_encrypters_for)

  role          = "roles/cloudkms.cryptoKeyEncrypter"
  crypto_key_id = local.keys_by_name[element(var.set_encrypters_for, count.index)]
  members       = compact(split(",", var.encrypters[count.index]))
}
