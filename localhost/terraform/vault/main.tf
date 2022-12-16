provider "vault" {
  ca_cert_file = "../../tools/certs/vault-cert.pem"
}

terraform {
  backend "s3" {
    bucket = "kubefirst-state-store"
    key     = "terraform/vault/tfstate.tf"
    endpoint = "http://minio.localdev.me"

    access_key="k-ray"
    secret_key="feedkraystars"
    region = "us-k3d-1"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
  }
}
