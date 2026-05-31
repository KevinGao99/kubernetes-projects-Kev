resource "aws_vpc" "main_vpc" {
  cidr_block           = local.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${local.environment}-${local.application}-vpc"
    Environment = local.environment
    Owner       = local.owner
    CostCenter  = local.cost_centers
    Application = local.application
  }

}