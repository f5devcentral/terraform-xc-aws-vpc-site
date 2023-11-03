provider "volterra" {
  api_p12_file = var.xc_api_p12_file
  url          = var.xc_api_url
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "aws_vpc_site" {
  source                = "../.."

  site_name             = "aws-example-ingress-egress-gw"
  aws_region            = "us-west-2"
  site_type             = "ingress_egress_gw"
  master_nodes_az_names = ["us-west-2a"]
  vpc_cidr              = "172.10.0.0/16"
  outside_subnets       = ["172.10.11.0/24"]
  workload_subnets      = ["172.10.21.0/24"]
  inside_subnets        = ["172.10.31.0/24"]

  aws_cloud_credentials_name = module.aws_cloud_credentials.name
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
    module.aws_cloud_credentials
  ]
}

module "aws_cloud_credentials" {
  source  = "f5devcentral/aws-cloud-credentials/xc"
  version = "0.0.3"

  tags = {
    key1 = "value1"
    key2 = "value2"
  }
  
  name           = "aws-tf-test-creds"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}
