resource "aws_security_group" "main_sg" {
  name        = "${local.environment}-${local.application}-main-sg"
  description = "security_group_for kubernetes"
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = merge(
    local.k8s_tags,
    {
      name = "${local.environment}-${local.application}-sg"
    }
  )
}