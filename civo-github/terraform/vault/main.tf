terraform {
  backend "s3" {
    bucket = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key     = "terraform/vault/tfstate.tf"
    endpoint = "https://objectstore.<CLOUD_REGION>.civo.com"

    # access_key = ""
    # secret_key = ""
    region = "<CLOUD_REGION>"

    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_region_validation = true
    force_path_style = true
  }
}
