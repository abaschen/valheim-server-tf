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
  access_key = "AKIAQ7RSVPHP6L2ZA64M"
  secret_key = "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"
}

data "aws_route53_zone" "selected" {
  name = "${var.domain}."
  private_zone = false
}