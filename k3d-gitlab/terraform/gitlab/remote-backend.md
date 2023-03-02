terraform {
  backend "s3" {
    bucket   = "kubefirst-state-store"
    key      = "terraform/gitlab/terraform.tfstate"
    endpoint = "http://minio.localdev.me"

    access_key                  = "k-ray"
    secret_key                  = "feedkraystars"
    region                      = "us-k3d-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
