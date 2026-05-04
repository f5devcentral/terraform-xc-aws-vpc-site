# AWS VPC Site for F5 Distributed Cloud (XC) Terraform Module

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/f5devcentral/aws-vpc-site/xc/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This Terraform module provisions an AWS VPC Site in F5 Distributed Cloud (XC). The module supports multiple AWS VPC Site types, including:

- **Ingress Gateway** - Single interface for inbound traffic
- **Ingress/Egress Gateway** - Dual interface for inbound and outbound traffic  
- **App Stack (Voltstack Cluster)** - Kubernetes-enabled cluster for running applications

It simplifies the AWS VPC Site creation process by populating default parameters, managing SSH keys, and parsing the Site Apply output.

> **Note**: This module is developed and maintained by the [F5 DevCentral](https://github.com/f5devcentral) community. You can use this module as an example for your own development projects.

## Requirements

| Name                                                                                                                 | Version    |
| -------------------------------------------------------------------------------------------------------------------- | ---------- |
| <a name="requirement_terraform"></a> [terraform](https://www.terraform.io/)                                          | >= 1.0     |
| <a name="requirement_aws"></a> [aws](https://registry.terraform.io/providers/hashicorp/aws/latest)                   | >= 4.65.0  |
| <a name="requirement_volterra"></a> [volterra](https://registry.terraform.io/providers/volterraedge/volterra/latest) | >= 0.11.49 |
| <a name="requirement_tls"></a> [tls](https://registry.terraform.io/providers/hashicorp/tls/latest)                   | >= 4.0     |
| <a name="requirement_time"></a> [time](https://registry.terraform.io/providers/hashicorp/time/latest)                | >= 0.9     |

### Prerequisites

- **F5 Distributed Cloud Account**: Active F5 XC account with API credentials
- **AWS Account**: AWS account with appropriate permissions
- **AWS Credentials**: Configured AWS CLI or environment variables
- **F5 XC API Certificate**: P12 certificate file for API authentication

## Usage

Here are examples of how to use the module for different site types:

### Ingress Gateway Site

```hcl
module "aws_vpc_site_ingress" {
  source  = "f5devcentral/aws-vpc-site/xc"
  version = "0.0.12"

  site_name                  = "aws-ingress-gw-site"
  aws_region                 = "us-west-2"
  site_type                  = "ingress_gw"
  master_nodes_az_names      = ["us-west-2a"]
  vpc_cidr                   = "172.10.0.0/16"
  local_subnets              = ["172.10.1.0/24"]
  aws_cloud_credentials_name = "your_aws_cloud_creds"
}
```

### Ingress/Egress Gateway Site

```hcl
module "aws_vpc_site_ingress_egress" {
  source  = "f5devcentral/aws-vpc-site/xc"
  version = "0.0.12"

  site_name             = "aws-ingress-egress-gw-site"
  aws_region            = "us-west-2"
  site_type             = "ingress_egress_gw"
  master_nodes_az_names = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_cidr              = "172.10.0.0/16"
  local_subnets         = ["172.10.1.0/24", "172.10.2.0/24", "172.10.3.0/24"]
  inside_subnets        = ["172.10.11.0/24", "172.10.12.0/24", "172.10.13.0/24"]
  outside_subnets       = ["172.10.21.0/24", "172.10.22.0/24", "172.10.23.0/24"]
  workload_subnets      = ["172.10.31.0/24", "172.10.32.0/24", "172.10.33.0/24"]
  
  aws_cloud_credentials_name = "your_aws_cloud_creds"
}
```

### App Stack (Kubernetes) Site

```hcl
module "aws_vpc_site_app_stack" {
  source  = "f5devcentral/aws-vpc-site/xc"
  version = "0.0.12"

  site_name             = "aws-app-stack-site"
  aws_region            = "us-west-2"
  site_type             = "app_stack"
  master_nodes_az_names = ["us-west-2a"]
  vpc_cidr              = "172.10.0.0/16"
  local_subnets         = ["172.10.1.0/24"]
  
  # Kubernetes configuration
  k8s_cluster = {
    name = "my-k8s-cluster"
  }
  default_storage = true
  
  aws_cloud_credentials_name = "your_aws_cloud_creds"
}
```

You can find additional usage examples in the "examples" folder of this module:

- [examples/aws-vpc-site-ingress-gw](examples/aws-vpc-site-ingress-gw) - Ingress Gateway with single AZ
- [examples/aws-vpc-site-ingress-gw-existing-vpc](examples/aws-vpc-site-ingress-gw-existing-vpc) - Ingress Gateway with existing VPC
- [examples/aws-vpc-site-ingress-egress-gw-single-az](examples/aws-vpc-site-ingress-egress-gw-single-az) - Ingress/Egress Gateway with single AZ
- [examples/aws-vpc-site-ingress-egress-gw-multi-az](examples/aws-vpc-site-ingress-egress-gw-multi-az) - Ingress/Egress Gateway with multiple AZs
- [examples/aws-vpc-site-app-stack](examples/aws-vpc-site-app-stack) - App Stack (Kubernetes) site

## Inputs

| Name                       | Description                                                                                                 | Type            | Default        | Required |
| -------------------------- | ----------------------------------------------------------------------------------------------------------- | --------------- | -------------- | :------: |
| site_name                  | The name of the AWS VPC Site that will be configured                                                        | `string`        | `""`           |   yes    |
| site_type                  | Site type: `ingress_gw`, `ingress_egress_gw`, or `app_stack`                                                | `string`        | `"ingress_gw"` |    no    |
| aws_region                 | Name for AWS Region                                                                                         | `string`        | `""`           |   yes    |
| master_nodes_az_names      | Availability Zone Names for Master Nodes                                                                    | `list(string)`  | `[]`           |   yes    |
| aws_cloud_credentials_name | AWS Cloud Credentials Name                                                                                  | `string`        | `null`         |   yes    |
| vpc_cidr                   | The Primary IPv4 block cannot be modified. All subnets prefixes in this VPC must be part of this CIDR block | `string`        | `null`         |    no    |
| create_aws_vpc             | Create AWS VPC                                                                                              | `bool`          | `true`         |    no    |
| instance_type              | Select Instance size based on performance needed                                                            | `string`        | `"t3.xlarge"`  |    no    |
| nodes_disk_size            | Disk size to be used for nodes in GiB. 80 is 80 GiB                                                         | `number`        | `80`           |    no    |
| site_description           | The description for the AWS VPC Site that will be configured                                                | `string`        | `null`         |    no    |
| site_namespace             | The namespace where AWS VPC Site that will be configured                                                    | `string`        | `"system"`     |    no    |
| enable_internet_vip        | VIPs can be advertised to the internet directly on this Site                                                | `bool`          | `false`        |    no    |
| k8s_cluster                | Kubernetes cluster configuration (app_stack only)                                                           | `object({...})` | `null`         |    no    |
| default_storage            | Use default storage class (app_stack only)                                                                  | `bool`          | `true`         |    no    |

> **Note**: This table shows the most commonly used inputs. See [variables.tf](variables.tf) for the complete list of all available variables.

## Outputs

| Name                    | Description                                          |
| ----------------------- | ---------------------------------------------------- |
| name                    | Site name                                            |
| id                      | Site ID                                              |
| vpc_id                  | AWS VPC ID                                           |
| local_subnet_ids        | List of local subnet IDs                             |
| inside_subnet_ids       | List of inside subnet IDs (ingress_egress_gw only)   |
| outside_subnet_ids      | List of outside subnet IDs (ingress_egress_gw only)  |
| workload_subnet_ids     | List of workload subnet IDs (ingress_egress_gw only) |
| ssh_private_key_openssh | Generated SSH private key                            |
| ssh_public_key          | Generated SSH public key                             |
| apply_tf_output_map     | Parsed Terraform apply output                        |

> **Note**: See [outputs.tf](outputs.tf) for the complete list of outputs.

## Troubleshooting

### Common Issues

**Site creation times out**
- F5 XC site creation can take 15-30 minutes
- Increase `apply_action_wait_for_action` if needed
- Check F5 XC console for site status

**SSH connectivity issues**
- Use the generated SSH key from module outputs
- Ensure security group allows SSH (port 22)
- Check AWS instance status and networking

**Kubernetes not available (App Stack)**
- Verify `k8s_cluster` configuration is provided
- Check site status in F5 XC console
- Ensure sufficient resources for K8s workloads

**VPC/Subnet conflicts**
- Check CIDR blocks don't overlap with existing networks
- Verify subnet sizes are adequate for the number of nodes
- Review AWS VPC quotas and limits

### Getting Help

- Check the [F5 Distributed Cloud documentation](https://docs.cloud.f5.com/)
- Review the [examples](examples/) directory
- Open an issue in this repository for bugs or feature requests

## Contributing

We welcome contributions to this module! Here's how you can help:

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/f5devcentral/terraform-xc-aws-vpc-site.git
   cd terraform-xc-aws-vpc-site
   ```

2. **Install dependencies**
   - [Terraform](https://terraform.io/downloads) >= 1.0
   - [TFLint](https://github.com/terraform-linters/tflint) (optional)
   - AWS CLI configured with appropriate credentials
   - F5 XC API credentials

3. **Run tests**
   ```bash
   terraform fmt -recursive -check
   terraform validate
   # Run example configurations
   ```

### Contribution Guidelines

- Follow [Terraform best practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- Add examples for new features
- Update documentation for any changes
- Test changes with real F5 XC/AWS resources when possible
- Follow conventional commit messages

### Adding New Features

1. Update `variables.tf` with new input variables
2. Implement the feature in `main.tf`
3. Update `outputs.tf` if applicable
4. Add or update examples in `examples/`
5. Update this README with documentation
6. Test the implementation

## License


This module is licensed under the Apache 2.0 License.
