# Terraform AWS WireGuard

A Terraform module to deploy a WireGuard VPN server on AWS.

### Prerequisites
Before using this module, you'll need to:

1. Install the [WireGuard tools](https://www.wireguard.com/install/) for your OS.

2. Generate a key pair for each client:
   ```bash
   wg genkey | tee client1-privatekey | wg pubkey > client1-publickey
   ```

3. Generate a key pair for the server
   ```bash
   wg genkey | tee server-privatekey | wg pubkey > server-publickey
   ```
4. Add each client's public key, along with the next available IP address to the `wg_clients` list.

5. Add server's private key to the `wg_server_private_key` variable. You can use AWS SSM Parameter store to store and read server private key.


<!-- BEGINNING OF GENERATED BY TERRAFORM-DOCS -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.wireguard_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_eip.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.wireguard_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.wireguard_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.wireguard_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.wireguard_roleattach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_configuration.wireguard_launch_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_route53_record.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.sg_wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.wireguard_policy_doc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.wg_client_data_json](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The name of environment for WireGuard. Used to differentiate multiple deployments. | `any` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The machine type to launch, some machines may offer higher throughput for higher use cases. | `string` | `"t3.nano"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_route53_hosted_zone_id"></a> [route53\_hosted\_zone\_id](#input\_route53\_hosted\_zone\_id) | Route53 Hosted zone ID. | `string` | `null` | no |
| <a name="input_route53_record_name"></a> [route53\_record\_name](#input\_route53\_record\_name) | Route53 Record name. | `string` | `null` | no |
| <a name="input_ssh_key_id"></a> [ssh\_key\_id](#input\_ssh\_key\_id) | A SSH public key ID to add to the VPN instance. | `any` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list. | `list(string)` | n/a | yes |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | Running a scaling group behind an LB requires this variable, default null means it won't be included if not set. | `list(string)` | `null` | no |
| <a name="input_use_eip"></a> [use\_eip](#input\_use\_eip) | Whether to enable Elastic IP switching code in user-data on wg server startup. If true, eip\_id must also be set to the ID of the Elastic IP. | `bool` | `false` | no |
| <a name="input_use_route53"></a> [use\_route53](#input\_use\_route53) | Whether to use Route53 | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID in which Terraform will launch the resources. | `any` | n/a | yes |
| <a name="input_wg_clients"></a> [wg\_clients](#input\_wg\_clients) | List of client objects with IP and public key. See Usage in README for details. | `list(object({ client_friendly_name = string, client_public_key = string, client_allowed_cidr = string }))` | n/a | yes |
| <a name="input_wg_persistent_keepalive"></a> [wg\_persistent\_keepalive](#input\_wg\_persistent\_keepalive) | Persistent Keepalive - useful for helping connection stability over NATs. | `number` | `25` | no |
| <a name="input_wg_server_interface"></a> [wg\_server\_interface](#input\_wg\_server\_interface) | The default interface to forward network traffic to. | `string` | `"eth0"` | no |
| <a name="input_wg_server_net"></a> [wg\_server\_net](#input\_wg\_server\_net) | IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1 | `string` | `"10.0.0.1/24"` | no |
| <a name="input_wg_server_port"></a> [wg\_server\_port](#input\_wg\_server\_port) | Port for the vpn server. | `number` | `51820` | no |
| <a name="input_wg_server_private_key"></a> [wg\_server\_private\_key](#input\_wg\_server\_private\_key) | WG server private key. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF GENERATED BY TERRAFORM-DOCS -->
