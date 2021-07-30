variable "region" {
  type = string
}

variable "env" {
  description = "The name of environment for WireGuard. Used to differentiate multiple deployments."
}

variable "ssh_key_id" {
  description = "A SSH public key ID to add to the VPN instance."
}

variable "instance_type" {
  default     = "t3.nano"
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
}

variable "vpc_id" {
  description = "The VPC ID in which Terraform will launch the resources."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list."
}

variable "wg_clients" {
  type        = list(object({ client_friendly_name = string, client_public_key = string, client_allowed_cidr = string }))
  description = "List of client objects with IP and public key. See Usage in README for details."
}

variable "wg_server_net" {
  default     = "10.0.0.1/24"
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
}

variable "wg_server_port" {
  default     = 51820
  description = "Port for the vpn server."
}

variable "wg_persistent_keepalive" {
  default     = 25
  description = "Persistent Keepalive - useful for helping connection stability over NATs."
}

variable "use_eip" {
  type        = bool
  default     = false
  description = "Whether to enable Elastic IP switching code in user-data on wg server startup. If true, eip_id must also be set to the ID of the Elastic IP."
}

variable "target_group_arns" {
  type        = list(string)
  default     = null
  description = "Running a scaling group behind an LB requires this variable, default null means it won't be included if not set."
}

variable "wg_server_private_key" {
  type        = string
  description = "WG server private key."
}

variable "wg_server_interface" {
  default     = "eth0"
  description = "The default interface to forward network traffic to."
}

variable "use_route53" {
  type        = bool
  default     = false
  description = "Whether to use Route53"
}

variable "route53_hosted_zone_id" {
  type        = string
  default     = null
  description = "Route53 Hosted zone ID."
}

variable "route53_record_name" {
  type        = string
  default     = null
  description = "Route53 Record name."
}
