terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
  access_key = var.aws_key
  secret_key = var.aws_secret
}

data "aws_route53_zone" "selected" {
  name = "${var.domain}."
  private_zone = false
}