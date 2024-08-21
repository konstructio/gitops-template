provider "vault" {
  skip_tls_verify = "true"
}

terraform {
  backend "s3" {
    bucket   = "kubefirst-state-store"
    key      = "terraform/vault/terraform.tfstate"
    endpoint = "https://minio.kubefirst.dev"

    access_key                  = "k-ray"
    secret_key                  = "feedkraystars"
    region                      = "us-k3d-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
