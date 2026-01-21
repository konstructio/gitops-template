data "aws_caller_identity" "this" {}

locals {
  role_name = data.aws_caller_identity.this.account_id == "<AWS_ACCOUNT_ID>" ? "<CLUSTER_NAME>-KubernetesAdmin" : "kubefirst-pro-api-<CLUSTER_NAME>"
}

resource "aws_eks_access_entry" "cluster_owner" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/${local.role_name}"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_owner" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/${local.role_name}"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.cluster_owner
  ]
}
