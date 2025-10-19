data "aws_availability_zones" "available" {}

locals {
  cluster_version = "1.31"
  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    kubefirst = "true"
  }
}

data "aws_caller_identity" "kubefirst_mgmt" {
  provider = aws.kubefirst_mgmt_s3_bucket_region
}

################################################################################
# S3 Bucket
################################################################################

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "k1-bu-mgmt-${var.cluster_name}"

  force_destroy = true
  versioning = {
    enabled = true
  }

  tags = local.tags
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  create_kms_key                 = false
  cluster_encryption_config      = {}

  access_entries = {
    "argocd_${var.cluster_name}" = {
      cluster_name  = "${var.cluster_name}"
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:role/argocd-mgmt-kgetpods-biz"
      policy_associations = {
        argocdAdminAccess = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
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
    ami_type       = var.ami_type
    instance_types = [var.node_type]
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
      desired_size = tonumber(var.node_count)      # tonumber() is used for a string token value
      min_size     = tonumber(1)                   # tonumber() is used for a string token value
      max_size     = tonumber(var.node_count) + 10 # tonumber() is used for a string token value
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      disk_size = 50
    }
  }

  enable_cluster_creator_admin_permissions = true
  tags                                     = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# Avoid collisions for generated values
resource "random_integer" "id" {
  min = 1000
  max = 9999
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.9.0"

  name = var.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_ipv6            = false
  create_egress_only_igw = false

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
  version = "~> 5.42.0"

  role_name             = upper("VPC-CNI-IRSA-${var.cluster_name}")
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
  version = "~> 5.42.0"

  role_name = upper("EBS-CSI-DRIVER-${var.cluster_name}")

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
  name        = "aws-ebs-csi-driver-${var.cluster_name}-${random_integer.id.result}"
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

resource "aws_iam_openid_connect_provider" "eks" {
  provider = aws.kubefirst_mgmt_s3_bucket_region
  url             = module.eks.cluster_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

module "cert_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.42.0"

  providers = {
    aws = aws.kubefirst_mgmt_s3_bucket_region
  }
  
  role_name = "cert-manager-${var.cluster_name}"
  role_policy_arns = {
    cert_manager = aws_iam_policy.cert_manager.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:oidc-provider/${module.eks.oidc_provider}"
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "cert_manager" {
  provider = aws.kubefirst_mgmt_s3_bucket_region
  
  name        = "cert-manager-${var.cluster_name}-${random_integer.id.result}"
  path        = "/"
  description = "policy for cert-manager to access route53 resources"

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


module "external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.42.0"

  providers = {
    aws = aws.kubefirst_mgmt_s3_bucket_region
  }

  role_name = "external-dns-${var.cluster_name}"
  role_policy_arns = {
    external_dns = aws_iam_policy.external_dns.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:oidc-provider/${module.eks.oidc_provider}"
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "external_dns" {
  provider = aws.kubefirst_mgmt_s3_bucket_region
  
  name        = "external-dns-${var.cluster_name}-${random_integer.id.result}"
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

module "crossplane_kubefirst_mgmt" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.42.0"

  providers = {
    aws = aws.kubefirst_mgmt_s3_bucket_region
  }

  role_name = "crossplane-${var.cluster_name}"
  
  role_policy_arns = {
    admin = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:oidc-provider/${module.eks.oidc_provider}"
      namespace_service_accounts = ["crossplane-system:crossplane-provider-terraform-${var.cluster_name}"]
    }
  }

  tags = local.tags
}

module "external_secrets_operator" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.40.0"

  role_name = "eso-${var.cluster_name}"
  role_policy_arns = {
    external_secrets_operator = aws_iam_policy.external_secrets_operator.arn
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "external-secrets-operator:external-secrets",
        "argocd:external-secrets"
        ]
    }
  }

  tags = local.tags
  
}

resource "aws_iam_policy" "external_secrets_operator" {
  name = "external-secrets-operator-${var.cluster_name}"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : ["*"]
      }
    ]
  })
} 

resource "vault_generic_secret" "clusters" {
  path = "secret/clusters/${var.cluster_name}"

  data_json = jsonencode(
    {
      cluster_ca_certificate = module.eks.cluster_certificate_authority_data
      host                   = module.eks.cluster_endpoint
      cluster_name           = var.cluster_name
      environment            = var.cluster_name
      argocd_role_arn        = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:role/argocd-mgmt-kgetpods-biz"
    }
  )
}


module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.40.0"

  role_name = "cluster-autoscaler-${var.cluster_name}"
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
  name = "cluster-autoscaler-${var.cluster_name}"
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

module "crossplane_custom_trust" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.33.0"

  create_role = true

  role_name = "crossplane-${var.cluster_name}"

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
      variable = "${split("arn:aws:iam::${var.account_id}:oidc-provider/", module.eks.oidc_provider_arn)[1]}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${split("arn:aws:iam::${var.account_id}:oidc-provider/", module.eks.oidc_provider_arn)[1]}:sub"
      values   = ["system:serviceaccount:crossplane-system:crossplane-provider-terraform-${var.cluster_name}"]
    }

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
  }
}

module "argocd" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.46.0"

  role_name = "argocd-${var.cluster_name}"
  role_policy_arns = {
    argocd = "arn:aws:iam::aws:policy/AdministratorAccess",
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

module "ack-ecr" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.40.0"

  role_name = "ack-ecr-${var.cluster_name}"
  role_policy_arns = {
    ack-ecr = aws_iam_policy.ack-ecr.arn
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ack-system:ack-ecr-controller"]
    }
  }

  tags = local.tags
  
}

resource "aws_iam_policy" "ack-ecr" {
  name = "ack-ecr-${var.cluster_name}"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid": "ECRRepositoryManagement",
        "Effect": "Allow",
        "Action": [
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ECRImageTagMutability",
        "Effect": "Allow",
        "Action": [
          "ecr:PutImageTagMutability"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ECRLifecyclePolicy",
        "Effect": "Allow",
        "Action": [
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy"
        ],
        "Resource": "*"
      },
      {
        "Sid": "ECRRepositoryPolicy",
        "Effect": "Allow",
        "Action": [
          "ecr:SetRepositoryPolicy",
          "ecr:GetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy"
        ],
        "Resource": "*"
      }
    ]
  })
} 
