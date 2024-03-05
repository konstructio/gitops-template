terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/vault/terraform.tfstate"
    endpoint = "https://<CLUSTER_NAME>.us-east-1.linodeobjects.com" #! edit

    region = "us-east-1" #! edit

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
  required_providers {
    civo = {
      source = "civo/civo"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
}

# export CIVO_TOKEN=$MYTOKEN is set 
provider "civo" {
  region = "<CLOUD_REGION>"
}

provider "vault" {
  skip_tls_verify = "true"
}
