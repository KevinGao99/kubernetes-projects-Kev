terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "terraform-state-${local.aws_region}-${local.aws_account_id}"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

