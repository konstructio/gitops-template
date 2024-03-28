output "node_iam_role_name" {
  value = module.eks.eks_managed_node_groups.default_node_group.iam_role_name
}

output "external_dns_policy_arn" {
  value = aws_iam_policy.external_dns.arn
}