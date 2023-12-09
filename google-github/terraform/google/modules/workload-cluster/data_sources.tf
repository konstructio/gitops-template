################
# Data Sources #
################

# IAM

data "google_iam_role" "artifactregistry_reader" {
  name = "roles/artifactregistry.reader"
}

data "google_iam_role" "crypto_key_encrypter_decrypter" {
  name = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}

data "google_iam_role" "dns_admin" {
  name = "roles/dns.admin"
}

data "google_iam_role" "owner" {
  name = "roles/owner"
}

data "google_iam_role" "secretmanager_secretaccessor" {
  name = "roles/secretmanager.secretAccessor"
}

data "google_iam_role" "storage_admin" {
  name = "roles/storage.admin"
}

data "google_iam_role" "storage_objectadmin" {
  name = "roles/storage.objectAdmin"
}

data "google_iam_role" "workload_identity_user" {
  name = "roles/iam.workloadIdentityUser"
}
