# Template Tokens Reference

This document lists all template tokens used in this DigitalOcean + GitHub cloud provider configuration. These tokens are replaced during the GitOps template instantiation process.

> **⚠️ Security Warning**: Never store sensitive information like API keys, passwords, or secrets directly in token values. Use proper secret management systems like Vault, Kubernetes secrets, or your cloud provider's secret management service.

## Token Categories

### Cloud Infrastructure

| Token | Template Value | Description |
|-------|---------------|-------------|
| `CLOUD_PROVIDER` | `<CLOUD_PROVIDER>` | Cloud provider name (digitalocean) |
| `CLOUD_REGION` | `<CLOUD_REGION>` | DigitalOcean region for deployment |
| `NODE_COUNT` | `<NODE_COUNT>` | Number of worker nodes |
| `NODE_TYPE` | `<NODE_TYPE>` | Droplet size for nodes |

### Cluster Configuration

| Token | Template Value | Description |
|-------|---------------|-------------|
| `CLUSTER_ID` | `<CLUSTER_ID>` | Unique cluster identifier |
| `CLUSTER_NAME` | `<CLUSTER_NAME>` | DOKS cluster name |
| `CLUSTER_TYPE` | `<CLUSTER_TYPE>` | Type of cluster deployment |
| `KUBE_CONFIG_PATH` | `<KUBE_CONFIG_PATH>` | Path to kubeconfig file |

### DNS and Networking

| Token | Template Value | Description |
|-------|---------------|-------------|
| `DOMAIN_NAME` | `<DOMAIN_NAME>` | Base domain for all services |
| `EXTERNAL_DNS_DOMAIN_NAME` | `<EXTERNAL_DNS_DOMAIN_NAME>` | Domain for external DNS |
| `EXTERNAL_DNS_PROVIDER_NAME` | `<EXTERNAL_DNS_PROVIDER_NAME>` | DNS provider (digitalocean, cloudflare, etc.) |
| `EXTERNAL_DNS_PROVIDER_TOKEN_ENV_NAME` | `<EXTERNAL_DNS_PROVIDER_TOKEN_ENV_NAME>` | Environment variable for DNS token |

### Application URLs

| Token | Template Value | Description |
|-------|---------------|-------------|
| `ARGOCD_INGRESS_URL` | `<ARGOCD_INGRESS_URL>` | ArgoCD web interface URL |
| `ARGO_WORKFLOWS_INGRESS_URL` | `<ARGO_WORKFLOWS_INGRESS_URL>` | Argo Workflows web interface URL |
| `ATLANTIS_INGRESS_URL` | `<ATLANTIS_INGRESS_URL>` | Atlantis web interface URL |
| `CHARTMUSEUM_INGRESS_URL` | `<CHARTMUSEUM_INGRESS_URL>` | Chart Museum web interface URL |
| `VAULT_INGRESS_URL` | `<VAULT_INGRESS_URL>` | Vault web interface URL |
| `VAULT_INGRESS_NO_HTTPS_URL` | `<VAULT_INGRESS_NO_HTTPS_URL>` | Vault URL without HTTPS |

### Sample Application URLs

| Token | Template Value | Description |
|-------|---------------|-------------|
| `METAPHOR_DEVELOPMENT_INGRESS_URL` | `<METAPHOR_DEVELOPMENT_INGRESS_URL>` | Development environment URL |
| `METAPHOR_STAGING_INGRESS_URL` | `<METAPHOR_STAGING_INGRESS_URL>` | Staging environment URL |
| `METAPHOR_PRODUCTION_INGRESS_URL` | `<METAPHOR_PRODUCTION_INGRESS_URL>` | Production environment URL |

### Git Configuration

| Token | Template Value | Description |
|-------|---------------|-------------|
| `GIT_FQDN` | `<GIT_FQDN>` | Fully qualified domain name for Git |
| `GIT_PROVIDER` | `<GIT_PROVIDER>` | Git provider name (github) |
| `GITHUB_HOST` | `<GITHUB_HOST>` | GitHub hostname |
| `GITHUB_OWNER` | `<GITHUB_OWNER>` | GitHub organization/user |
| `GITHUB_USER` | `<GITHUB_USER>` | GitHub username |
| `GITOPS_REPO_URL` | `<GITOPS_REPO_URL>` | GitOps repository URL |
| `GITOPS_REPO_ATLANTIS_WEBHOOK_URL` | `<GITOPS_REPO_ATLANTIS_WEBHOOK_URL>` | Webhook URL for Atlantis |

### Storage and Registry

| Token | Template Value | Description |
|-------|---------------|-------------|
| `CONTAINER_REGISTRY_URL` | `<CONTAINER_REGISTRY_URL>` | Container registry URL |
| `KUBEFIRST_ARTIFACTS_BUCKET` | `<KUBEFIRST_ARTIFACTS_BUCKET>` | Spaces bucket for artifacts |
| `KUBEFIRST_STATE_STORE_BUCKET` | `<KUBEFIRST_STATE_STORE_BUCKET>` | Spaces bucket for Terraform state |
| `KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME` | `<KUBEFIRST_STATE_STORE_BUCKET_HOSTNAME>` | Hostname for state bucket |
| `VAULT_DATA_BUCKET` | `<VAULT_DATA_BUCKET>` | Spaces bucket for Vault data |

### Platform Configuration

| Token | Template Value | Description |
|-------|---------------|-------------|
| `ALERTS_EMAIL` | `<ALERTS_EMAIL>` | Email for platform alerts |
| `ATLANTIS_ALLOW_LIST` | `<ATLANTIS_ALLOW_LIST>` | Allowed repositories for Atlantis |
| `KUBEFIRST_CLIENT` | `<KUBEFIRST_CLIENT>` | Kubefirst client identifier |
| `KUBEFIRST_TEAM` | `<KUBEFIRST_TEAM>` | Team name |
| `KUBEFIRST_TEAM_INFO` | `<KUBEFIRST_TEAM_INFO>` | Additional team information |
| `KUBEFIRST_VERSION` | `<KUBEFIRST_VERSION>` | Kubefirst platform version |
| `ORIGIN_ISSUER_IS_ENABLED` | `<ORIGIN_ISSUER_IS_ENABLED>` | Whether Cloudflare Origin CA issuer is enabled |
| `USE_TELEMETRY` | `<USE_TELEMETRY>` | Enable/disable telemetry |

### Workload Clusters

| Token | Template Value | Description |
|-------|---------------|-------------|
| `WORKLOAD_CLUSTER_BOOTSTRAP_TERRAFORM_MODULE_URL` | `<WORKLOAD_CLUSTER_BOOTSTRAP_TERRAFORM_MODULE_URL>` | Terraform module for bootstrap |
| `WORKLOAD_CLUSTER_NAME` | `<WORKLOAD_CLUSTER_NAME>` | Name of workload cluster |
| `WORKLOAD_CLUSTER_REGION` | `<WORKLOAD_CLUSTER_REGION>` | Region for workload cluster |
| `WORKLOAD_CLUSTER_TERRAFORM_MODULE_URL` | `<WORKLOAD_CLUSTER_TERRAFORM_MODULE_URL>` | Terraform module URL |
| `WORKLOAD_ENVIRONMENT` | `<WORKLOAD_ENVIRONMENT>` | Environment name for workload |
| `WORKLOAD_EXTERNAL_DNS_DOMAIN_NAME` | `<WORKLOAD_EXTERNAL_DNS_DOMAIN_NAME>` | DNS domain for workload cluster |
| `WORKLOAD_NODE_COUNT` | `<WORKLOAD_NODE_COUNT>` | Number of nodes in workload cluster |
| `WORKLOAD_NODE_TYPE` | `<WORKLOAD_NODE_TYPE>` | Droplet size for workload nodes |

### Workload Cluster Custom Inputs

| Token | Template Value | Description |
|-------|---------------|-------------|
| `EXAMPLE_INPUT_TOKEN` | `<EXAMPLE_INPUT_TOKEN>` | Demonstration Custom Input from Workload Cluster Template |

## Usage Notes

- These tokens are automatically replaced during template instantiation
- Token values should not contain sensitive information
- All URLs will be generated based on your domain configuration
- DigitalOcean uses Spaces for object storage (S3-compatible)
- DOKS provides managed Kubernetes with simple pricing