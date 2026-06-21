resource "aws_lb" "kubernetes_nlb" {
  name               = "${local.environment}-${local.application}-nlb"
  subnets            = [aws_subnet.k8s_subnet.id]
  internal           = local.internal_nlb
  load_balancer_type = local.load_balancer_type

  tags = merge(
    { name = "${local.environment}-${local.application}-nlb" },
    local.k8s_tags
  )
}

resource "aws_lb_target_group" "main_tg" {
  name        = "${local.environment}-${local.application}-target-group"
  port        = local.target_group_port
  protocol    = local.target_group_protocol
  vpc_id      = aws_vpc.main_vpc.id
  target_type = local.target_group_target_type

  tags = merge(
    { name = "${local.environment}-${local.application}-target-group" },
    local.k8s_tags
  )
}

resource "aws_lb_target_group_attachment" "target_ip_attachment" {
  count            = length(local.target_ips)
  target_group_arn = aws_lb_target_group.main_tg.arn
  target_id        = local.target_ips[count.index]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.kubernetes_nlb.arn
  port              = local.lb_listener_port
  protocol          = local.lb_listener_protocol
  default_action {
    type             = local.lb_listener_default_action_type
    target_group_arn = aws_lb_target_group.main_tg.arn
  }
  tags = merge(
    {
      name = "${local.environment}-${local.application}-lb-listener"
    },
    local.k8s_tags
  )

}