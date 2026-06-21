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

  public_subnet_cidr_blocks = "10.0.1.0/24"

  # Security Group
  # CIDR Ingress Variables
  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/16", "10.200.0.0/16"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Route Table
  destination_cidr_block  = "0.0.0.0/0"
  pod_network_cidr_blocks = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]

  # Network Load Balancer
  target_ips               = ["10.0.1.10", "10.0.1.11", "10.0.1.12"]
  load_balancer_type       = "network"
  target_group_port        = 6443
  target_group_protocol    = "TCP"
  target_group_target_type = "ip"

  lb_listener_port                = 443
  lb_listener_protocol            = "TCP"
  lb_listener_default_action_type = "forward"
  k8s_tags = {
    owner        = local.owner
    environment  = local.environment
    cost_centers = local.cost_centers
    application  = local.application
  }

  # Worker Instance
  worker_instance_count        = 3
  worker_image_id              = "ami-0a15226b1f7f23580"
  worker_instance_type         = "t3.micro"
  worker_key_name              = "kubernetes"
  worker_associate_public_ip   = true
  worker_private_ip_prefix     = "10.0.1.2"
  worker_ebs_block_device_name = "/dev/sda1"
  worker_ebs_block_volume_size = 50
  source_dest_check            = false
  # Disable source/destination check to allow workers to route traffic for pod IPs (10.200.x.0/24)
  # and service IPs (10.32.0.0/24) that don't belong to the instance itself. Required for kube-proxy
  # iptables rules to work correctly when redirecting service traffic to pod endpoints.

  # controller Instance
  controller_instance_count        = 3
  controller_image_id              = "ami-0a15226b1f7f23580"
  controller_instance_type         = "t3.micro"
  controller_key_name              = "kubernetes"
  controller_associate_public_ip   = true
  controller_private_ip_prefix     = "10.0.1.1"
  controller_ebs_block_volume_size = 50

  internal_nlb = false
}