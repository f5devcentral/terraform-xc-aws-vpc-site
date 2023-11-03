# Ingress GW AWS VPC Site with single AZ for F5 XC Cloud

The following example will create an Ingress GW AWS VPC Site in F5 XC Cloud with single AZ and a security group. The security groups will be configured with whitelisted IP ranges.

```hcl
module "aws_vpc_site_ingress_gw" {
  source                     = "../.."

  site_name                  = "aws-example-ingress-gw"
  aws_region                 = "us-west-2"
  site_type                  = "ingress_gw"
  master_nodes_az_names      = ["us-west-2a"]
  vpc_cidr                   = "172.10.0.0/16"
  local_subnets              = ["172.10.1.0/24"]

  aws_cloud_credentials_name = module.aws-cloud-credentials.volterra_cloud_credentials_name
  block_all_services         = false

  tags = {
    key1 = "value1"
    key2 = "value2"
  }

  depends_on = [ 
    module.aws-cloud-credentials
  ]
}
```