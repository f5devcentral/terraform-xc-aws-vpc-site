# AWS VPC Site for F5 Distributed Cloud (XC) Terraform module

This Terraform module provisions an AWS VPC Site in F5 Distributed Cloud (XC). The module supports multiple AWS VPC Site types, including "Ingress Gateway", "Ingress/Egress Gateway" or "App Stack." It simplifies the AWS VPC Site creation process by populating default parameters, managing SSH keys, and parsing the Site Apply output.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](https://github.com/hashicorp/terraform) | >= 1.0 |
| <a name="requirement_volterra"></a> [volterra](https://registry.terraform.io/providers/volterraedge/volterra/latest) | >= 0.11.26 |

## Usage


Here is a short example of how to use the module:

```hcl
module "aws_vpc_site_ig" {
  source                     = "f5devcentral/aws-vpc-site/xc"
  version                    = "0.0.1"

  site_name                  = "aws-ingress-gw-site"
  aws_region                 = "eu-west-2"
  master_nodes_az_names      = ["eu-west-2a"]
  vpc_cidr                   = "172.10.0.0/16"
  local_subnets              = ["172.10.1.0/24"]
  aws_cloud_credentials_name = "your_aws_cloud_creds_name"
}
```

You can find additional usage examples in the "examples" folder of this module.


## Contributing

Contributions to this module are welcome! Please see the contribution guidelines for more information.

## License

This module is licensed under the Apache 2.0 License.