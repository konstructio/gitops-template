output "vault_unseal_kms_key" {
  // todo https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v4.0.0/examples/iam-assumable-role-with-oidc
  value = module.kms.vault_unseal_kms_key
}
