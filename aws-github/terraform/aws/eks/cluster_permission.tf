data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

data "aws_iam_policy_document" "assume_kubernetes_admin" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_session_context.current.issuer_arn]
    }
  }
}

data "aws_iam_policy_document" "describe_cluster" {
  statement {
    actions = [
      "eks:DescribeCluster"
    ]
    resources = ["arn:aws:eks:*:*:cluster/*"]
  }
}

resource "aws_iam_role" "kubernetes_admin" {
  name               = "<CLUSTER_NAME>-KubernetesAdmin"
  assume_role_policy = data.aws_iam_policy_document.assume_kubernetes_admin.json
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name   = "DescribeCluster"
  role   = aws_iam_role.kubernetes_admin.id
  policy = data.aws_iam_policy_document.describe_cluster.json
}

resource "aws_eks_access_entry" "cluster_owner" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.kubernetes_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_owner" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.kubernetes_admin.arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.cluster_owner
  ]
}
