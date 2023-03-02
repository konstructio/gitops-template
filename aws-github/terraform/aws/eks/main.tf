terraform {
  required_version = ">= 0.12.0"
}

provider "local" {
  version = "~> 2.1.0"
}

provider "null" {
  version = "~> 3.1.0"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "<CLUSTER_NAME>"
}
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "kubefirst-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}

module "eks" {
  version         = "17.24.0"
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true
  # write_kubeconfig = false
  manage_aws_auth = false

  kubeconfig_output_path = "../../../kubeconfig"

  vpc_id = module.vpc.vpc_id
}

module "iam_assumable_role_argo_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:argo:argo"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "argo-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  tags = {
    Role = "Argo"
  }
}

module "iam_assumable_role_atlantis_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:atlantis:atlantis"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "atlantis-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  tags = {
    Role = "Atlantis"
  }
}

module "iam_assumable_role_cert_manager_route53" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "cert-manager-${local.cluster_name}"
  role_policy_arns = [
    aws_iam_policy.cert_manager.arn,
  ]
  tags = {
    Role = "CertManager"
  }
}

resource "aws_iam_policy" "cert_manager" {
  name        = "cert-manager-<CLUSTER_NAME>"
  path        = "/"
  description = "policy for external dns to access route53 resources"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
EOT
}


module "iam_assumable_role_chartmuseum_s3" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:chartmuseum:chartmuseum"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "chartmuseum-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
  tags = {
    Role = "Chartmuseum"
  }
}

module "iam_assumable_role_external_dns_route53" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:external-dns:external-dns"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "external-dns-${local.cluster_name}"
  role_policy_arns = [
    aws_iam_policy.external_dns.arn,
  ]
  tags = {
    Role = "ExternalDns"
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "external-dns-<CLUSTER_NAME>"
  path        = "/"
  description = "policy for external dns to access route53 resources"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOT
}

module "iam_assumable_role_vault_dynamo_kms" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version                       = "4.0.0"
  create_role                   = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:vault:vault"]
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_name                     = "vault-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
    aws_iam_policy.vault_server.arn
  ]
  tags = {
    Role = "Vault"
  }
}

resource "aws_iam_policy" "vault_server" {
  name        = "vault-unseal-<CLUSTER_NAME>"
  path        = "/"
  description = "policy for external dns to access route53 resources"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VaultAWSAuthMethod",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile",
        "iam:GetUser",
        "iam:GetRole"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "VaultKMSUnseal",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOT
}


resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.12.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_node_group" "mgmt_nodes" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "mgmt-nodes"
  node_role_arn   = module.eks.worker_iam_role_arn
  subnet_ids      = module.vpc.private_subnets
  ami_type        = var.ami_type
  instance_types  = [var.instance_type]
  disk_size       = 50

  capacity_type = var.node_capacity_type

  labels = {
    workload      = "mgmt"
    ClusterName   = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }

  scaling_config {
    desired_size = 7
    max_size     = 7
    min_size     = 7
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.eks
  ]
}
