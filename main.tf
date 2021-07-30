resource "aws_eip" "wireguard" {
  vpc = true
  tags = {
    Name = "${var.env}-wireguard"
  }
}

resource "aws_route53_record" "wireguard" {
  count           = var.use_route53 ? 1 : 0
  allow_overwrite = true
  set_identifier  = "${var.env}-${var.region}-wireguard"
  zone_id         = var.route53_hosted_zone_id
  name            = var.route53_record_name
  type            = "A"
  ttl             = "60"
  records         = [aws_eip.wireguard.public_ip]
}

data "template_file" "wg_client_data_json" {
  template = file("${path.module}/templates/client-data.tpl")
  count    = length(var.wg_clients)

  vars = {
    client_friendly_name = var.wg_clients[count.index].client_friendly_name
    client_public_key    = var.wg_clients[count.index].client_public_key
    client_allowed_cidr  = var.wg_clients[count.index].client_allowed_cidr
    persistent_keepalive = var.wg_persistent_keepalive
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "wireguard_launch_config" {
  name_prefix          = "${var.env}-wireguard-"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = var.ssh_key_id
  iam_instance_profile = (var.use_eip ? aws_iam_instance_profile.wireguard_profile[0].name : null)
  user_data = templatefile("${path.module}/templates/user-data.txt", {
    wg_server_private_key = var.wg_server_private_key,
    wg_server_net         = var.wg_server_net,
    wg_server_port        = var.wg_server_port,
    peers                 = join("\n", data.template_file.wg_client_data_json.*.rendered),
    use_eip               = var.use_eip ? "enabled" : "disabled",
    eip_id                = aws_eip.wireguard.id,
    wg_server_interface   = var.wg_server_interface
  })
  security_groups             = [aws_security_group.sg_wireguard.id]
  associate_public_ip_address = var.use_eip

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wireguard_asg" {
  name                 = aws_launch_configuration.wireguard_launch_config.name
  launch_configuration = aws_launch_configuration.wireguard_launch_config.name
  min_size             = 1
  desired_capacity     = 1
  max_size             = 1
  vpc_zone_identifier  = var.subnet_ids
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = aws_launch_configuration.wireguard_launch_config.name
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "wireguard"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = var.env
      propagate_at_launch = true
    },
    {
      key                 = "tf-managed"
      value               = "True"
      propagate_at_launch = true
    },
  ]
}
