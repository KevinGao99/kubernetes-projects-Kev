resource "aws_subnet" "k8s_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = local.public_subnet_cidr_blocks
  tags = merge(
    local.k8s_tags,
    {
      name = "${local.environment}-{local.application}-public-subnet"
    }
  )
}
