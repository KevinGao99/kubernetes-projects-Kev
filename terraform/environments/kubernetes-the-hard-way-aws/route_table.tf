resource "aws_route_table" "main_rtb" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    local.k8s_tags,
    { name = "${local.environment}-${local.application}-main-route-table" }
  )
}

resource "aws_route" "main_route" {
  route_table_id         = aws_route_table.main_rtb.id
  destination_cidr_block = local.destination_cidr_block
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route" "pod_network_route" {
  count                  = length(local.pod_network_cidr_blocks)
  network_interface_id   = aws_instance.kubernetes_workers[count.index].primary_networker_interface_id
  destination_cidr_block = "${local.pod_network_cidr_blocks[count.index]}"
  route_table_id         = aws_route_table.main_rtb.id
}

resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.k8s_subnet.id
  route_table_id = aws_route_table.main_rtb.id
}