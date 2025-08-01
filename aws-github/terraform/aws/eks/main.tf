provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data != null ? module.eks.cluster_certificate_authority_data : "")

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name            = "<CLUSTER_NAME>"
  cluster_version = "1.31"
  region          = "<CLOUD_REGION>"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    kubefirst = "true"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  create_kms_key                 = false
  cluster_encryption_config      = {}
  cluster_addons = {
    # AWS launch CoreDNS itself with their add-on https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
    # coredns = {
    #   most_recent = true
    #   resolve_conflicts = "OVERWRITE"
    # }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.aws_ebs_csi_driver.iam_role_arn
      configuration_values = jsonencode({
        defaultStorageClass = {
          enabled = true
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "<AMI_TYPE>"
    instance_types = ["<NODE_TYPE>"]

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      desired_size = tonumber("<NODE_COUNT>")      # tonumber() is used for a string token value
      min_size     = tonumber("1")                 # tonumber() is used for a string token value
      max_size     = tonumber("<NODE_COUNT>") + 10 # tonumber() is used for a string token value
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      disk_size = 50
    }
  }

  # Enable admin permissions for the cluster creator
  enable_cluster_creator_admin_permissions = true

  access_entries = {

    "argocd_<CLUSTER_NAME>" = {
      cluster_name  = "<CLUSTER_NAME>"
      principal_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd-<CLUSTER_NAME>"
      username      = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd-<CLUSTER_NAME>"
      policy_associations = {
        view_deployments = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }

    "atlantis_<CLUSTER_NAME>" = {
      cluster_name  = "<CLUSTER_NAME>"
      principal_arn = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/atlantis-<CLUSTER_NAME>"
      username      = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/atlantis-<CLUSTER_NAME>"
      policy_associations = {
        view_deployments = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_ipv6            = false
  create_egress_only_igw = true

  public_subnet_ipv6_prefixes  = [0, 1, 2]
  private_subnet_ipv6_prefixes = [3, 4, 5]
  intra_subnet_ipv6_prefixes   = [6, 7, 8]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name             = upper("VPC-CNI-IRSA-<CLUSTER_NAME>")
  attach_vpc_cni_policy = true
  role_policy_arns = {
    AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }


  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "aws_ebs_csi_driver" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = upper("EBS-CSI-DRIVER-<CLUSTER_NAME>")

  role_policy_arns = {
    admin = aws_iam_policy.aws_ebs_csi_driver.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node", "kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "aws_ebs_csi_driver" {
  name        = "aws-ebs-csi-driver-${local.name}"
  path        = "/"
  description = "policy for aws ebs csi driver"

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:snapshot/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "CreateVolume",
            "CreateSnapshot"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:snapshot/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/CSIVolumeName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CSIVolumeName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVolume"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/kubernetes.io/created-for/pvc/name": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOT
}

module "argo_workflows" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "argo-${local.name}"
  role_policy_arns = {
    admin = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argo:argo-server"]
    }
  }

  tags = local.tags
}

module "argocd" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "argocd-${local.name}"
  role_policy_arns = {
    argocd = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-application-controller", "argocd:argocd-server"]
    }
  }

  tags = local.tags
}

module "atlantis" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "atlantis-${local.name}"
  role_policy_arns = {
    atlantis = "arn:aws:iam::aws:policy/AdministratorAccess",
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["atlantis:atlantis"]
    }
  }

  tags = local.tags
}

module "cert_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "cert-manager-${local.name}"
  role_policy_arns = {
    cert_manager = aws_iam_policy.cert_manager.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "cert_manager" {
  name        = "cert-manager-${local.name}"
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

module "chartmuseum" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "chartmuseum-${local.name}"
  role_policy_arns = {
    chartmuseum = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["chartmuseum:chartmuseum"]
    }
  }

  tags = local.tags
}

module "crossplane_custom_trust" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.33.0"

  create_role = true

  role_name = "crossplane-${local.name}"

  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.crossplane_custom_trust_policy.json
  custom_role_policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_iam_policy_document" "crossplane_custom_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${split("arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/", module.eks.oidc_provider_arn)[1]}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${split("arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub"
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-<CLUSTER_NAME>"]
    }

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::<AWS_ACCOUNT_ID>:role/KubernetesAdmin"]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::<AWS_ACCOUNT_ID>:role/argocd-${local.name}"]
    }
  }
}

module "ecr_publish_permissions_sync" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "ecr-publish-permissions-sync-${local.name}"
  role_policy_arns = {
    admin = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argo:ecr-publish-permissions-sync"]
    }
  }

  tags = local.tags
}

module "external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "external-dns-${local.name}"
  role_policy_arns = {
    external_dns = aws_iam_policy.external_dns.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "external_dns" {
  name        = "external-dns-${local.name}"
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

resource "aws_iam_policy" "ssm_access_policy" {
  name = "kubefirst-pro-api-ssm-access-${local.name}"
  description = "Policy to allow SSM actions for kubefirst-pro-api"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Statement1",
        Effect = "Allow",
        Action = [
          "ssm:*"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

module "kubefirst_api" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "kubefirst-pro-api-${local.name}"
  role_policy_arns = {
    kubefirst = "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    ssm       = aws_iam_policy.ssm_access_policy.arn
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kubefirst:kubefirst-pro-api"]
    }
  }
  tags = local.tags
}

module "vault" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "vault-${local.name}"
  role_policy_arns = {
    dynamo = aws_iam_policy.vault_dynamodb.arn,
    kms    = aws_iam_policy.vault_kms.arn,
    vault  = aws_iam_policy.vault_server.arn,
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["vault:vault"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "vault_server" {
  name        = "vault-unseal-${local.name}"
  path        = "/"
  description = "vault server kms unseal policy"

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


module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "cluster-autoscaler-${local.name}"
  role_policy_arns = {
    cluster_autoscalert = aws_iam_policy.cluster_autoscaler.arn
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = local.tags
}


resource "aws_iam_policy" "cluster_autoscaler" {
  name = "cluster-autoscaler-${local.name}"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_policy" "vault_dynamodb" {
  name = "vault-dynamodb-${local.name}"
  path = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Query",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "vault_kms" {
  name = "vault-kms-${local.name}"
  path = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}
