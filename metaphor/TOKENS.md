# Metaphor Application Tokens

This document lists all template tokens used in the Metaphor sample application. The Metaphor app serves as a demonstration of how applications are deployed and managed in the Kubefirst GitOps platform.

> **⚠️ Security Warning**: Never store sensitive information like API keys, passwords, or secrets directly in token values. Use proper secret management systems like Vault or Kubernetes secrets.

## Application Tokens

| Token | Template Value | Description |
|-------|---------------|-------------|
| `CONTAINER_REGISTRY_URL` | `<CONTAINER_REGISTRY_URL>` | Container registry where Metaphor images are stored |
| `DOMAIN_NAME` | `<DOMAIN_NAME>` | Base domain for the application URLs |
| `KUBEFIRST_VERSION` | `<KUBEFIRST_VERSION>` | Platform version displayed in the UI |
| `ORIGIN_ISSUER_IS_ENABLED` | `<ORIGIN_ISSUER_IS_ENABLED>` | Whether Cloudflare Origin CA issuer is enabled |

## Application URLs

The Metaphor application is deployed to multiple environments with the following URL pattern:

| Environment | URL Template |
|-------------|--------------|
| Development | `https://metaphor-development.<DOMAIN_NAME>` |
| Staging | `https://metaphor-staging.<DOMAIN_NAME>` |
| Production | `https://metaphor-production.<DOMAIN_NAME>` |

## Usage Notes

- Container images are built and pushed to the configured registry
- The application demonstrates GitOps deployment patterns
- Each environment has its own Helm values and configuration
- SSL certificates are automatically managed when deployed