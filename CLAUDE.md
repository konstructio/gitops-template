# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the Kubefirst GitOps template repository containing infrastructure as code (IaC) and GitOps configurations for multi-cloud Kubernetes deployments. The repository supports multiple cloud providers (AWS, Azure, Google Cloud, Civo, DigitalOcean, Vultr, Akamai) and Git providers (GitHub, GitLab).

## Key Architecture Components

1. **Multi-Cloud Templates**: Each cloud-git provider combination (e.g., `aws-github/`, `azure-gitlab/`) contains:
   - `/registry/` - ArgoCD application manifests for environments
   - `/templates/` - Kubernetes manifests for platform components
   - `/terraform/` - Infrastructure provisioning code
   - `atlantis.yaml` - Terraform automation configuration

2. **Platform Applications**: Managed via ArgoCD including:
   - ArgoCD (GitOps CD)
   - Argo Workflows (CI)
   - Atlantis (Terraform automation)
   - Vault (secrets management)
   - External Secrets Operator
   - Cert Manager
   - Ingress controllers
   - Crossplane (for workload clusters)

3. **Metaphor Application**: Sample Next.js application in `/metaphor/` demonstrating the deployment pattern

## Common Development Commands

### Terraform Operations
```bash
# Format all Terraform files
make fmt

# Validate all Terraform configurations
make validate

# Manual Terraform operations (Atlantis handles PR automation)
cd terraform/<provider>
terraform init
terraform plan
terraform apply
```

### Metaphor Application Development
```bash
cd metaphor

# Install dependencies
npm install

# Development server
npm run dev

# Build application
npm run build

# Linting
npm run lint
npm run lint:fix

# Format code
npm run format
```

## Working with GitOps Templates

1. **Application Deployment Pattern**:
   - Applications are registered in `/registry/environments/` (development, staging, production)
   - ArgoCD syncs from the registry to deploy applications
   - Templates in `/templates/` define the base configurations

2. **Adding New Applications**:
   - Create manifests in appropriate `/templates/` directory
   - Register in `/registry/environments/` for the target environment
   - Follow existing patterns for naming and structure

3. **Terraform Changes**:
   - Modifications to `*.tf` files trigger Atlantis workflows
   - Pull requests automatically generate terraform plans
   - Apply changes through PR comments after approval

## Important Conventions

1. **Branch Strategy**:
   - `main` branch represents production GitOps state
   - Feature branches for all changes
   - Atlantis manages terraform applies via PRs

2. **Secrets Management**:
   - Never commit secrets directly
   - Use Vault for secret storage
   - External Secrets Operator syncs to Kubernetes

3. **Dependency Management**:
   - Renovate bot manages dependency updates
   - Configured for Terraform, ArgoCD, and Kustomize

4. **Cloud Provider Patterns**:
   - Each provider follows similar directory structure
   - Provider-specific configurations in terraform directories
   - Shared platform components in templates

## Testing and Validation

- Terraform: Use `make validate` to check all configurations
- Kubernetes manifests: Validated through ArgoCD dry-runs
- Application code: Provider-specific testing (e.g., `npm run lint` for Metaphor)