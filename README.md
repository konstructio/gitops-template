<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="logo.png" alt="Kubefirst Logo">
    <img alt="" src="logo.png">
  </picture>
</p>
<p align="center">
  Kubefirst Instant GitOps Platforms
</p>

<p align="center">
  <a href="https://docs.kubefirst.io/">Install</a>&nbsp;|&nbsp;
  <a href="https://twitter.com/kubefirst">Twitter</a>&nbsp;|&nbsp;
  <a href="https://www.linkedin.com/company/kubefirst">LinkedIn</a>&nbsp;|&nbsp;
  <a href="https://join.slack.com/t/kubefirst/shared_invite/zt-r0r9cfts-OVnH0ooELDLm9n9p2aU7fw">Slack</a>&nbsp;|&nbsp;
  <a href="https://kubefirst.io/blog">Blog</a>
</p>

# gitops

The `gitops` repository has 2 main sections

- `/registry`: the argocd gitops application registry for each of our clusters
- `/terraform`: infrastructure as code & configuration as code for your cloud, git provider, vault, and user resources

## kubefirst apps

The [kubefirst cli](https://github.com/kubefirst/kubefirst) has established the following applications:

| Application              | Namespace        | Description                                 | URL (where applicable)   |
| ------------------------ | ---------------- | ------------------------------------------- | ------------------------ |
| <GIT_PROVIDER>           | <GIT_NAMESPACE>  | <GIT_DESCRIPTION>                           | <GIT_URL>                |
| Vault                    | vault            | Secrets Management                          | <VAULT_INGRESS_URL>              |
| Argo CD                  | argocd           | GitOps Continuous Delivery                  | <ARGOCD_INGRESS_URL>            |
| Argo Workflows           | argo             | Application Continuous Integration          | <ARGO_WORKFLOWS_INGRESS_URL>     |
| Atlantis                 | atlantis         | Terraform Workflow Automation               | <ATLANTIS_INGRESS_URL>           |
| Chart Museum             | chartmuseum      | Helm Chart Registry                         | <CHARTMUSEUM_INGRESS_URL>        |
| Metaphor Development     | development      | Development instance of sample application  | <METAPHOR_DEVELOPMENT_INGRESS_URL>     |
| Metaphor Staging         | staging          | Staging instance of sample application      | <METAPHOR_FRONT_STAGING> |
| Metaphor Production      | production       | Production instance of sample application   | <METAPHOR_FRONT_PROD>    |
| Nginx Ingress Controller | ingress-nginx    | Ingress Controller                          |                          |
| Cert Manager             | cert-manager     | Certificate Automation Utility              |                          |
| Certificate Issuers      | clusterwide      | Let's Encrypt browser-trusted certificates  |                          |
| External Secrets         | external-secrets | Syncs Kubernetes secrets with Vault secrets |                          |
| <GIT_RUNNER>             | <GIT_RUNNER_NS>  | <GIT_RUNNER_DESCRIPTION>                    |                          |

---

## gitops registry

The argocd configurations in this repo can be found in the [registry directory](./registry). The applications that we build and release on the kubefirst platform will also be registered here in the development, staging, and production folders. The `metaphor` application can be found there to serve as an example to follow for building and shipping code on the platform.

The `main` branch's registry directory represents the gitops desired state for all apps registered with kubernetes. Argo CD will automatically apply your desired state to kubernetes through. You can see the Sync status of all of your apps in [argo cd](<ARGO_CD_URL>).

## terraform infrastructure as code

The terraform in this repository can be found in the [terraform directory](./terraform). It has entry points for management of cloud resources, vault configurations, git provider configurations, and user management.

All of our terraform is automated with a tool called atlantis that integrates with your git pull requests. To see the terraform entry points and under what circumstance they are triggered, see [atlantis.yaml](./atlantis.yaml).

Any change to a `*.tf` file, even a whitespace change, will trigger its corresponding Atlantis workflow once a pull request is submitted. Within a minute it will post the plan to the pull request with instruction on how to apply the plan if approved.
