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

  vpc_tags = {
    "ClusterName"   = "${local.cluster_name}"
    "ProvisionedBy" = "kubefirst"
  }
}

module "eks" {
  version         = "17.20.0"
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true 
  # write_kubeconfig = false
  manage_aws_auth = false
  
  # TODO: prevent creation of iam
  # workers_role_name = "worker-node-role-fever-dreams"
  
  kubeconfig_output_path = "./kubeconfig"
    
  tags = {
    ClusterName = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }

  vpc_id = module.vpc.vpc_id

  map_roles = concat(var.map_roles, [{
    rolearn  = "arn:aws:iam::${var.aws_account_id}:role/KubernetesAdmin"
    username = "admin"
    groups   = ["system:masters"]
    }, {
    rolearn  = "arn:aws:iam::${var.aws_account_id}:role/atlantis-${local.cluster_name}"
    username = "admin"
    groups   = ["system:masters"]
    }, {
    rolearn  = aws_iam_role.kubefirst_worker_nodes_role.arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:bootstrappers", "system:nodes"]
  }])
  map_accounts = var.map_accounts
}

module "iam_assumable_role_argo_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version = "4.0.0"
  create_role = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:argo:argo"]
  provider_url  = module.eks.cluster_oidc_issuer_url
  role_name = "argo-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  tags = {
    Role = "Argo"
    ClusterName = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }
}
  
module "iam_assumable_role_atlantis_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version = "4.0.0"
  create_role = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:atlantis:atlantis"]
  provider_url  = module.eks.cluster_oidc_issuer_url
  role_name = "atlantis-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  tags = {
    Role = "Atlantis"
    ClusterName = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }
}

module "iam_assumable_role_chartmuseum_s3" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version = "4.0.0"
  create_role = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:chartmuseum:chartmuseum"]
  provider_url  = module.eks.cluster_oidc_issuer_url
  role_name = "chartmuseum-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
  tags = {
    Role = "Chartmuseum"
    ClusterName = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }
}

module "iam_assumable_role_vault_dynamo_kms" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  version = "4.0.0"
  create_role = true
  oidc_fully_qualified_subjects = ["system:serviceaccount:vault:vault"]
  provider_url  = module.eks.cluster_oidc_issuer_url
  role_name = "vault-${local.cluster_name}"
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
  ]
  tags = {
    Role = "Vault"
    ClusterName = "${local.cluster_name}"
    ProvisionedBy = "kubefirst"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_id
  addon_name   = "vpc-cni"
  addon_version = "v1.11.2-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_node_group" "mgmt_nodes" {
  cluster_name    = module.eks.cluster_id
  node_group_name = "mgmt-nodes"
  node_role_arn   = aws_iam_role.kubefirst_worker_nodes_role.arn
  subnet_ids      = module.vpc.private_subnets
  ami_type        = var.ami_type
  instance_types  = [var.instance_type]
  disk_size       = 50

  capacity_type = var.lifecycle_nodes

  labels = {
    workload = "mgmt"
    ClusterName = "${local.cluster_name}"
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
