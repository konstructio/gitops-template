locals {
  keys_by_name = zipmap(var.keys, google_kms_crypto_key.key[*].id)
}

variable "project" {
  description = "GCP Project ID"
  type        = string
}


variable "decrypters" {
  description = "List of comma-separated owners for each key declared in set_decrypters_for."
  type        = list(string)

  default = []
}

variable "encrypters" {
  description = "List of comma-separated owners for each key declared in set_encrypters_for."
  type        = list(string)

  default = []
}

variable "keyring" {
  description = "The name of the KeyRing that will be created."

  type = string
}

variable "keys" {
  description = "Key names for keys that will be created and added to the KeyRing."
  type        = list(string)

  default = []
}

variable "key_rotation_period" {
  description = "Every time this period passes, generate a new CryptoKeyVersion and set it as the primary. The first rotation will take place after the specified period. The rotation period has the format of a decimal number with up to 9 fractional digits, followed by the letter s (seconds)."
  type        = string

  default = "100000s"
}

variable "location" {
  description = "The location for the KeyRing."
  type        = string

  default = "global"
}

variable "owners" {
  description = "List of comma-separated owners for each key declared in set_owners_for."
  type        = list(string)

  default = []
}

variable "set_decrypters_for" {
  description = "Name of keys for which decrypters will be set."
  type        = list(string)

  default = []
}

variable "set_encrypters_for" {
  description = "Name of keys for which encrypters will be set."
  type        = list(string)

  default = []
}

variable "set_owners_for" {
  description = "Name of keys for which owners will be set."
  type        = list(string)

  default = []
}
