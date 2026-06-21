resource "aws_instance" "kubernetes_controllers" {
  count                       = local.controller_instance_count
  associate_public_ip_address = local.controller_associate_public_ip
  ami                         = local.controller_image_id
  key_name                    = local.controller_key_name
  security_groups             = [aws_security_group.main_sg.id]
  instance_type               = local.controller_instance_type
  private_ip                  = "${local.controller_private_ip_prefix}.${count.index}"
  user_data                   = "name=k8s-controller-${count.index}"
  subnet_id                   = aws_subnet.k8s_subnet.id
  source_dest_check           = false
  root_block_device {
    volume_size = local.controller_ebs_block_volume_size
  }
  lifecycle {
    prevent_destroy = false
  }
  tags = merge(
    local.k8s_tags,
    { Name = "${local.environment}-${local.application}-controller-${count.index}" }
  )
}

resource "aws_instance" "kubernetes_workers" {
  count                       = local.worker_instance_count
  ami                         = local.worker_image_id
  instance_type               = local.worker_instance_type
  key_name                    = local.worker_key_name
  security_groups             = [aws_security_group.main_sg.id]
  associate_public_ip_address = local.worker_associate_public_ip
  subnet_id                   = aws_subnet.k8s_subnet.id
  private_ip                  = "${local.worker_private_ip_prefix}${count.index}"
  user_data                   = "name=worker-${count.index}|pod-cidr=10.200.${count.index}.0.24"
  source_dest_check           = local.source_dest_check
  ebs_block_device {
    device_name = local.worker_ebs_block_device_name
    volume_size = local.worker_ebs_block_volume_size
  }
  tags = merge(
    local.k8s_tags,
    {
      name = "${local.environment}-{local.application}-worker-${count.index}"
    }
  )
}