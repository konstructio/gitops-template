data "aws_ssm_parameter" "cluster" {
  provider = aws.business_mgmt_region
  name = "/clusters/${var.host_cluster}"
}

data "aws_eks_cluster" "cluster" {
  name = var.host_cluster
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.host_cluster
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  cluster_config = jsondecode(data.aws_ssm_parameter.cluster.value)
  oidc_issuer_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  oidc_provider   = replace(local.oidc_issuer_url, "https://", "")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
}

provider "kubernetes" {
  alias = "incluster"
}

provider "helm" {
    kubernetes = {
        host                   = local.cluster_config.host
        cluster_ca_certificate = base64decode(local.cluster_config.cluster_ca_certificate)
        token                  = data.aws_eks_cluster_auth.cluster.token
    }   
}

locals {
  vcluster_host = "${var.vcluster_name}.${var.domain_name}"
  
  original_kubeconfig = data.kubernetes_secret.vcluster_kubeconfig.data["config"]
  
  modified_kubeconfig = replace(
    local.original_kubeconfig,
    "/server:\\s*https://[^:]+(?::\\d+)?/",
    "server: https://${local.vcluster_host}"
  )
}

resource "helm_release" "my_vcluster" {
  name             = var.vcluster_name
  namespace        = var.vcluster_name
  create_namespace = true

  repository       = "https://charts.loft.sh"
  chart            = "vcluster"
  version          = "0.24.0"

  values = [
    templatefile("${path.module}/values.yaml", {
      vcluster_name = var.vcluster_name
      domain_name   = var.domain_name
    })
  ]
}

data "kubernetes_secret" "vcluster_kubeconfig" {
  depends_on = [helm_release.my_vcluster]
  
  metadata {
    name      = "vc-${var.vcluster_name}"
    namespace = var.vcluster_name
  }
}

resource "kubernetes_secret" "example" {
  depends_on = [data.kubernetes_secret.vcluster_kubeconfig]
  provider   = kubernetes.incluster
  
  metadata {
    name      = "vc-${var.vcluster_name}"
    namespace = var.vcluster_name
  }

  data = {
    config = local.modified_kubeconfig
  }
}

data "aws_caller_identity" "kubefirst_mgmt" {
  provider = aws.kubefirst_mgmt_region
}

module "cert_manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.42.0"

   providers = {
    aws = aws.kubefirst_mgmt_region
  }

  role_name = "cert-manager-${var.vcluster_name}"
  role_policy_arns = {
    cert_manager = aws_iam_policy.cert_manager.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:oidc-provider/${local.oidc_provider}"
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

}

resource "random_integer" "id" {
  min = 1000
  max = 9999
}

resource "aws_iam_policy" "cert_manager" {
  provider = aws.kubefirst_mgmt_region
  name        = "cert-manager-${var.vcluster_name}-${random_integer.id.result}"
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


module "external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.42.0"

  providers = {
    aws = aws.kubefirst_mgmt_region
  }

  role_name = "external-dns-${var.vcluster_name}"
  role_policy_arns = {
    external_dns = aws_iam_policy.external_dns.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.kubefirst_mgmt.account_id}:oidc-provider/${local.oidc_provider}"
      namespace_service_accounts = ["${var.vcluster_name}:external-dns-x-external-dns-x-${var.vcluster_name}"]
    }
  }

}

resource "aws_iam_policy" "external_dns" {
  provider = aws.kubefirst_mgmt_region
  name        = "external-dns-${var.vcluster_name}-${random_integer.id.result}"
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

module "external_secrets_operator" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.40.0"

  role_name = "eso-${var.vcluster_name}"
  role_policy_arns = {
    external_secrets_operator = aws_iam_policy.external_secrets_operator.arn
  }
  assume_role_condition_test = "StringLike"
  allow_self_assume_role     = true
  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["${var.vcluster_name}:external-secrets-x-external-secrets-operator-x-${var.vcluster_name}"]
    }
  }  
}

resource "aws_iam_policy" "external_secrets_operator" {
  name = "external-secrets-operator-${var.vcluster_name}-${random_integer.id.result}"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.vcluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:ListSecrets"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        "Resource" : [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.vcluster_name}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeParameters"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : [
          "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
        ]
      }
    ]
  })
}

provider "kubernetes" {
  host                   = local.cluster_config.host
  cluster_ca_certificate = base64decode(local.cluster_config.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_role" "secret_reader" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name      = "secret-reader-${var.vcluster_name}"
    namespace = var.host_cluster 
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding" "allow_secret_access" {
  depends_on = [kubernetes_role.secret_reader]
  metadata {
    name      = "allow-secret-access-${var.vcluster_name}"
    namespace = var.host_cluster
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vcluster_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.secret_reader.metadata[0].name
  }
}

resource "kubernetes_role" "secret_reader_vcluster" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name      = "secret-reader-${var.vcluster_name}"
    namespace = var.vcluster_name 
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get"]
  }

}

resource "kubernetes_role_binding" "allow_secret_access_vcluster" {
  depends_on = [kubernetes_role.secret_reader]
  metadata {
    name      = "allow-secret-access-${var.vcluster_name}"
    namespace = var.vcluster_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vcluster_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.secret_reader_vcluster.metadata[0].name
  }
}

resource "kubernetes_service_account" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
}

resource "kubernetes_role" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }

  rule {
    api_groups     = ["apps"]
    resources      = ["deployments","statefulsets"]
    verbs          = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "example" {
  depends_on = [helm_release.my_vcluster]
  metadata {
    name = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-toolkit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-toolkit"
    namespace = "${var.vcluster_name}"
  }
}
