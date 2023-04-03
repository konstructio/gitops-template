<p align="center">
    <img src="logo.png"/>
</p>

`metaphor` is an example application which serves as a demonstration space for how your applications hook into your infrastructure and tooling.

`metaphor` is deployed to all of your environments just like your other applications will be. This means that when you make changes to your ci/cd, you can test it out using an application that works just like your applications do.

The cloud ([GitHub](https://docs.kubefirst.com/kubefirst/github/install.html)/[GitLab](https://docs.kubefirst.com/kubefirst/gitlab/install.html)) deployed instances of `metaphor` are available at:

| environment | url                                          |
| ----------- | -------------------------------------------- |
| development | `https://metaphor-development.<DOMAIN_NAME>` |
| staging     | `https://metaphor-staging.<DOMAIN_NAME>`     |
| production  | `https://metaphor-production.<DOMAIN_NAME>`  |

The [local](https://docs.kubefirst.com/kubefirst/local/install.html) deployed instances of `metaphor` is available at:

| environment | url                                          |
| ----------- | -------------------------------------------- |
| development | `https://metaphor-development.kubefirst.dev` |
| staging     | `https://metaphor-staging.kubefirst.dev`     |
| production  | `https://metaphor-production.kubefirst.dev`  |

`metaphor` currently demonstrates the following capabilities:

- building a docker container
- publishing a docker container to ecr
- publishing a prerelease helm chart
- gitops delivery of metaphor to different namespaces
- a release process that publishes a release chart and patches the chart version to prepare for the next release
- secrets sourced from vault
- certificate management using cert-manager
- automatic dns management using external-dns

# CI/CD

`metaphor` has 5 ci stages defined in its .gitlab-ci.yml file.

- branch: branch jobs run when your branch pushes to origin and report status to your merge requests
- publish: publishes your docker container to ecr and publishes your prerelease chart to chartmuseum
- development: sets the desired chart version for development
- staging: sets the desired chart version for staging
- release: publishes a release chart, sets the desired chart version for production, and patches chart in source for the next release

`argocd` is the gitops tool responsible for auto syncing the desired state in each environment. It follows a pull model so our CI/CD ecosystem doesn't need to know how to connect to our kubernetes clusters.

We have `metaphor` set up to run its automation by invoking argo-workflows. Those submitted workflows can be found in the .argo directory of this repository.

# Setup Instructions

- You will need `node` and `yarn` installed globally on your machine.
- Make sure you are using **NodeJS** >= v16.15.1
- Install dependencies `yarn install`
- Start the server `yarn dev`
- Go to `localhost:3000`
- Enjoy 🥳🎉
