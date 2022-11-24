![](logo.png)

# gitops

The `gitops` repository has 2 main section

- `/registry`: the argocd gitops app registry 
- `/terraform`: infrastructure as code & configuration as code

## kubefirst apps

The [kubefirst cli](https://github.com/kubefirst/kubefirst) has established the following applications:

| Application              | Namespace        | Description                                 | URL (where applicable)                              |
|--------------------------|------------------|---------------------------------------------|-----------------------------------------------------|
| <GIT_PROVIDER>           | <GIT_NAMESPACE>  | <GIT_DESCRIPTION>                           | <GIT_URL>                                           |
| Vault                    | vault            | Secrets Management                          | <VAULT_INGRESS_URL>                                 |
| Argo CD                  | argocd           | GitOps Continuous Delivery                  | <ARGOCD_INGRESS_URL>                                |
| Argo Workflows           | argo             | Application Continuous Integration          | <ARGO_WORKFLOWS_INGRESS_URL>                        |
| Atlantis                 | atlantis         | Terraform Workflow Automation               | <ATLANTIS_INGRESS_URL>                              |
| Chart Museum             | chartmuseum      | Helm Chart Registry                         | <CHARTMUSEUM_INGRESS_URL>                           |
| Metaphor Development     | development      | Development instance of sample application  | <METAPHOR_FRONTEND_DEVELOPMENT_INGRESS_URL>         |
| Metaphor Staging         | staging          | Staging instance of sample application      | <METAPHOR_FRONTEND_STAGING_INGRESS_URL>             |
| Metaphor Production      | production       | Production instance of sample application   | <METAPHOR_FRONTEND_PRODUCTION_INGRESS_URL>          |
| Nginx Ingress Controller | ingress-nginx    | Ingress Controller                          |                                                     |
| Cert Manager             | cert-manager     | Certificate Automation Utility              |                                                     |
| Certificate Issuers      | clusterwide      | Let's Encrypt browser-trusted certificates  |                                                     |
| External Secrets         | external-secrets | Syncs Kubernetes secrets with Vault secrets |                                                     |
| <GIT_RUNNER>             | <GIT_RUNNER_NS>  | <GIT_RUNNER_DESCRIPTION>                    |                                                     |

## argocd registry

The argocd configurations in this repo can be found in the [registry directory](./registry). The applications that you build and release on the kubefirst platform will also be registered here in the development, staging, and production folders. The `metaphor` app can be found there to serve as an example to follow.

The `main` branch of this repo represents the desired state all apps registered with kubernetes. Argo CD will automatically try to converge your desired state with the actual state in kubernetes with a process called Argo Sync. You can see the Sync status of all of your apps in the [argo cd ui](<ARGOCD_INGRESS_URL>).

## terraform infrastructure as code

The terraform in this repository can be found in the `/terraform` directory. 

All of our terraform is automated with atlantis. To see the terraform entry points and under what circumstance they are triggered, see [atlantis.yaml](./atlantis.yaml).

Any change to a `*.tf` file, even a whitespace change, will trigger its corresponding Atlantis workflow once a merge request is submitted in GitLab. Within a minute it will post the plan to the pull request with instruction on how to apply the plan if approved.

## terraform configuration as code

In addition to infrastructure terraform, the `gitops` repository also contains configuration as code for the following products:
- ArgoCD: The Argo CD app-registry, repositories, and secrets
- GitLab: Gitlab Repositories and ECR registries needed to house containers for those repositories
- Vault: auth backends, secrets engine, infrastructure secrets

## engineering onboarding

Your kubefirst platform comes with some terraform in place for managing [admins](./terraform/users/admins) and [developers](./terraform/users/developers). At the top of these two files, you'll find a list of sample admins and developers. Replace this list with the list of actual users you want added to the admin and developer groups and open a pull request. The pull request will show you the user changes in the terraform plan. When approved, have atlantis apply the plan with an `atlantis apply` comment in the pull request.

Your new users will have temporary passwords generated for them and stored in Vault in the `/users` secret store.

