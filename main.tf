provider "aws" {
  region = var.region  
  access_key = var.aws.id
  secret_key = var.aws.key
}

provider "aws" {
  # us-east-1 instance
  region = "us-east-1"
  alias = "cert-provider"
  access_key = var.aws.id
  secret_key = var.aws.key
}


data "aws_route53_zone" "selected" {
  name = "${var.domain}."
  private_zone = false
}