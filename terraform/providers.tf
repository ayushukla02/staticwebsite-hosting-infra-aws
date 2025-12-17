terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Main Provider (Your operational region - CDN, S3, Route53)
provider "aws" {
  region = var.aws_region
}

# ACM Provider (Strictly required for SSL Certificate only)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}