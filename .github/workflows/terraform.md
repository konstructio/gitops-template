name: Terraform
on:
  push:
  pull_request:
jobs:
  terraform-actions:
    name: Workflow
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4.1.6

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3.1.1

      - name: Terraform fmt
        run: |
          terraform fmt -check -recursive .
