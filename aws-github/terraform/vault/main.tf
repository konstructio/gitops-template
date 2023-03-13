terraform {
  backend "s3" {
    bucket   = "<KUBEFIRST_STATE_STORE_BUCKET>"
    key      = "terraform/vault/terraform.tfstate"

    region = "<CLOUD_REGION>"
    encrypt = true
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
