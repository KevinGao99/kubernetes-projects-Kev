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
    region       = local.aws_region
    use_lockfile = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.aws_region
}

