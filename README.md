# valheim-server-tf
Terraform deployment for valheim (or any docker image) on AWS Fargate with:
- Region Availability Zones
- no EKS cluster, direct docker deployment with Fargate
- Sub Domain registration with Route53
- VPC creation
- volumes

# Getting started

1. Go to cloud.terraform.io and create an account
2. Go to AWS and create a user with an access key for this deployment (for now admin, DO NOT share this to anyone ever)
3. Fork this project
4. In Terraform Cloud create a new workspace and checkout your forked project or a release
5. It will retrieve the code then you need to configure your variables, see `variables.tf` for all options. you can also commit them in your repository in `terraform.tfvars` which is ignored by git normally, remove the line mentioning the file in `.gitignore`. **DO NOT PUT ANY SECRET IN GIT!!** Your AWS account will be immediately flagged as compromised.
6. Plan your deployment (dry run)
7. Apply the deployment (real run) /!\ you will get billed starting from here based on what you've set in container resources (cpu/memory)

# Bugs

- Volume not mounting yet

# TODO

- more logs
- alerts
- list user roles for AWS to limit the scope
- release