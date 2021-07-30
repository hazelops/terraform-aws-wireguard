module "wireguard" {
  source  = "git@github.com:hazelops/terraform-aws-wireguard.git"
  env = your-env
region = your-aws-region
use_eip = true
ssh_key_id = "your-ec2-key-id"
subnet_ids = ["vpc-subnets"]
vpc_id = <"id-of-your-vpc">
wg_server_private_key = data.aws_ssm_parameter.wireguard_server_private_key.value
wg_clients = [
{ client_friendly_name = "user1"
  client_allowed_cidr = "10.0.0.3/24"
  client_public_key= "user1-public-key" },
{ client_friendly_name = "user2"
  client_allowed_cidr = "10.0.0.4/24"
  client_public_key= "user2-public-key" }
]
}

data "aws_ssm_parameter" "wireguard_server_private_key" {
name = "/global/wg-server-private-key"
}
