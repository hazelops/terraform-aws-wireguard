resource "aws_security_group" "sg_wireguard" {
  name        = "${var.env}-${var.aws_region}-wireguard"
  description = "Terraform Managed. Allow Wireguard client traffic from internet."
  vpc_id      = var.vpc_id

  tags = {
    Name       = "${var.env}-${var.aws_region}-wireguard"
    Project    = "wireguard"
    tf-managed = "True"
    env        = var.env
  }

  ingress {
    from_port   = var.wg_server_port
    to_port     = var.wg_server_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
