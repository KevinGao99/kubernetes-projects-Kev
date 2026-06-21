resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc
  tags = merge(
    local.k8s_tags,
    {
      name = "${local.environment}-${local.application}-igw"
    }
  )
}