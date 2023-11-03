# Ingress GW AWS VPC Site with single AZ and existing AWS VPC for F5 XC Cloud

The following example will create an Ingress GW AWS VPC Site in F5 XC Cloud with single AZ with existing AWS VPC and a security group. 

```hcl
module "aws_vpc_site_ingress_gw" {
  source                     = "../.."

  site_name              = "aws-example-ingress-gw"
  aws_region             = "us-west-2"
  site_type              = "ingress_gw"
  master_nodes_az_names  = ["us-west-2a"]
  create_aws_vpc         = false
  vpc_id                 = "your_vpc_id"
  existing_local_subnets = ["your_subnet_id"]

  custom_security_group = {
    outside_security_group_id = "your_security_group_id"
  }

  aws_cloud_credentials_name = "your_cloud_credentials_name"
}
```