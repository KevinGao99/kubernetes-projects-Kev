locals {
  # Global config
  aws_region = "us-west-2"
  # VPC config
  cidr_block = "10.0.0.0/16"
  # Tags
  owner        = "default"
  environment  = "kubernetes-the-hard-way-aws"
  cost_centers = "kubernetes-the-hard-way"
  application  = "k8s"
}