# Ingress/Egress GW AWS VPC Site with 3 AZs for F5 XC Cloud

The following example will create an Ingress/Egress GW AWS VPC Site in F5 XC Cloud with 3 AZs and a security group. The security groups will be configured with whitelisted IP ranges.

```hcl
module "aws_vpc_site_ingress_egress_gw_az" {
  source                = "../.."

  site_name             = "aws-example-ingress-egress-gw-az"
  aws_region            = "us-west-2"
  site_type             = "ingress_egress_gw"
  master_nodes_az_names = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_cidr              = "172.10.0.0/16"
  outside_subnets       = ["172.10.11.0/24", "172.10.12.0/24", "172.10.13.0/24"]
  workload_subnets      = ["172.10.21.0/24", "172.10.22.0/24", "172.10.23.0/24"]
  inside_subnets        = ["172.10.31.0/24", "172.10.32.0/24", "172.10.33.0/24"]

  aws_cloud_credentials_name = module.aws-cloud-credentials.volterra_cloud_credentials_name
  block_all_services         = false

  global_network_connections_list = [{ 
    sli_to_global_dr = { 
      global_vn = { 
        name = "sli-to-global-dr" 
      } 
    } 
  }] 

  tags = {
    key1 = "value1"
    key2 = "value2"
  }

  depends_on = [ 
    module.aws-cloud-credentials
  ]
}
```