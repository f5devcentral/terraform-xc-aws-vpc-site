variable "site_name" {
  description = "The name of the AWS VPC Site that will be configured."
  type        = string
  default     = ""
}

variable "site_description" {
  description = "The description for the AWS VPC Site that will be configured."
  type        = string
  default     = null
}

variable "site_namespace" {
  description = "The namespace where AWS VPC Site that will be configured."
  type        = string
  default     = "system"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "offline_survivability_mode" {
  description = "Enable/Disable offline survivability mode."
  type        = bool
  default     = false
}

variable "software_version" {
  description = "F5XC Software Version is optional parameter, which allows to specify target SW version for particular site e.g. crt-20210329-1002."
  type        = string
  default     = null
}

variable "operating_system_version" {
  description = "Operating System Version is optional parameter, which allows to specify target OS version for particular site e.g. 7.2009.10."
  type        = string
  default     = null
}

variable "site_type" {
  description = "The site_type variable is used to specify the type of site that will be deployed. Available values: ingress_gw, ingress_egress_gw, app_stack"
  type        = string
  default     = "ingress_gw"
}


variable "master_nodes_az_names" {
  description = "Availability Zone Names for Master Nodes."
  type        = list(string)
  default     = []
}

variable "nodes_disk_size" {
  description = "Disk size to be used fornodes in GiB. 80 is 80 GiB."
  type        = number
  default     = 80
}

#-----------------------------------------------------------
# SSH Key
#-----------------------------------------------------------

variable "ssh_key" {
  description = "Public SSH key for accessing the AWS VPC Site. If not provided, a new key will be generated."
  type        = string
  default     = null
}


#-----------------------------------------------------------
# AWS
#-----------------------------------------------------------

variable "aws_region" {
  description = "Name for AWS Region."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Select Instance size based on performance needed."
  type        = string
  default     = "t3.xlarge"
}

#-----------------------------------------------------------
# L3 Performance Mode
#-----------------------------------------------------------

variable "jumbo" {
  description = "L3 performance mode enhancement to use jumbo frame."
  type        = bool
  default     = null
}

#-----------------------------------------------------------
# AWS Cloud Credentials
#-----------------------------------------------------------

variable "aws_cloud_credentials_name" {
  description = "AWS Cloud Credentials Name."
  type        = string
  default     = null
}

variable "aws_cloud_credentials_namespace" {
  description = "AWS Cloud Credentials Namespace."
  type        = string
  default     = "system"
}

variable "aws_cloud_credentials_tenant" {
  description = "AWS Cloud Credentials Tenant."
  type        = string
  default     = null
}

#-----------------------------------------------------------
# Direct Connect
#-----------------------------------------------------------

variable "direct_connect" {
  description = "Direct Connect feature configuration."
  type = object({
    auto_asn = optional(bool)
    cloud_aggregated_prefix = optional(list(string))
    custom_asn = optional(number)
    dc_connect_aggregated_prefix = optional(list(string))
  })
  default = null
}

#-----------------------------------------------------------
# Egress
#-----------------------------------------------------------

variable "egress_nat_gw" {
  description = "Egress site traffic will be routed through an Network Address Translation(NAT) Gateway."
  type = object({
    nat_gw_id = optional(string)
  })
  default = null
}

variable "egress_virtual_private_gateway" {
  description = "Egress site traffic will be routed through an Virtual Private Gateway."
  type = object({
    vgw_id = optional(string)
  })
  default = null
}

#-----------------------------------------------------------
# VIP
#-----------------------------------------------------------

variable "enable_internet_vip" {
  description = "VIPs can be advertised to the internet directly on this Site."
  type        = bool
  default     = false
}

variable "allowed_vip_port" {
  description = "Allowed VIP Port Configuration for Outside Network."
  type = object({
    disable_allowed_vip_port = optional(bool)
    use_http_https_port      = optional(bool)
    use_http_port            = optional(bool)
    use_https_port           = optional(bool)
    custom_port_ranges       = optional(string)
  })
  default = {
    disable_allowed_vip_port = true
  }
}

variable "allowed_vip_port_sli" {
  description = "Allowed VIP Port Configuration for Inside Network."
  type = object({
    disable_allowed_vip_port = optional(bool)
    use_http_https_port      = optional(bool)
    use_http_port            = optional(bool)
    use_https_port           = optional(bool)
    custom_port_ranges       = optional(string)
  })
  default = {
    disable_allowed_vip_port = true
  }
}

#-----------------------------------------------------------
# Logs Streaming
#-----------------------------------------------------------

variable "log_receiver" {
  description = "Select log receiver for logs streaming."
  type = object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  })
  default = null
}

#-----------------------------------------------------------
# VPC
#-----------------------------------------------------------

variable "vpc_id" {
  description = "The ID of the existing AWS VPC where the resources will be provisioned."
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "The name of the autogenerated VPC where the resources will be provisioned."
  type        = string
  default     = null
}

variable "vpc_allocate_ipv6" {
  description = "Allocate IPv6 CIDR block from AWS."
  type        = bool
  default     = null
}

variable "vpc_cidr" {
  description = "The Primary IPv4 block cannot be modified. All subnets prefixes in this VPC must be part of this CIDR block."
  type        = string
  default     = null
}

variable "create_aws_vpc" {
  description = "Create AWS VPC."
  type        = string
  default     = true
}

#-----------------------------------------------------------
# Security Group
#-----------------------------------------------------------

variable "custom_security_group" {
  description = "With this option, ingress and egress traffic will be controlled via security group ids."
  type = object({
    inside_security_group_id  = optional(string)
    outside_security_group_id = optional(string)
  })
  default = null
}

#-----------------------------------------------------------
# Subnets
#-----------------------------------------------------------

variable "existing_local_subnets" {
  description = "If you want to use existing subnets, provide the subnet IDs here."
  type        = list(string)
  default     = []
}

variable "existing_inside_subnets" {
  description = "If you want to use existing subnets, provide the subnet IDs here."
  type        = list(string)
  default     = []
}

variable "existing_outside_subnets" {
  description = "If you want to use existing subnets, provide the subnet IDs here."
  type        = list(string)
  default     = []
}

variable "existing_workload_subnets" {
  description = "If you want to use existing subnets, provide the subnet IDs here."
  type        = list(string)
  default     = []
}

variable "local_subnets" {
  description = "Local Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "inside_subnets" {
  description = "Inside Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "outside_subnets" {
  description = "Outside Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "workload_subnets" {
  description = "Workload Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "local_subnets_ipv6" {
  description = "Local Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "inside_subnets_ipv6" {
  description = "Inside Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "outside_subnets_ipv6" {
  description = "Outside Subnets for the Site."
  type        = list(string)
  default     = []
}

variable "workload_subnets_ipv6" {
  description = "Workload Subnets for the Site."
  type        = list(string)
  default     = []
}

#-----------------------------------------------------------
# Worker Nodes
#-----------------------------------------------------------

variable "worker_nodes_per_az" {
  description = "Desired Worker Nodes Per AZ. Max limit is up to 21."
  type        = number
  default     = 0
}

#-----------------------------------------------------------
# Blocked Services
#-----------------------------------------------------------

variable "block_all_services" {
  description = "Block DNS, SSH & WebUI services on Site."
  type        = bool
  default     = true
}


variable "blocked_service" {
  description = "Use custom blocked services configuration."
  type = object({
    dns                = optional(bool)
    ssh                = optional(bool)
    web_user_interface = optional(bool)
    network_type       = optional(string)
  })
  default = null
}

#-----------------------------------------------------------
# Apply Action
#-----------------------------------------------------------

variable "apply_action_wait_for_action" {
  description = "Wait for terraform action job to complete."
  type        = bool
  default     = true
}

variable "apply_action_ignore_on_update" {
  description = "Ignore action to perform during update."
  type        = bool
  default     = false
}

#-----------------------------------------------------------
# DC Cluster Group
#-----------------------------------------------------------

variable "dc_cluster_group_inside_vn" {
  description = "This site is member of dc cluster group connected via inside network."
  type = object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  })
  default = null
}

variable "dc_cluster_group_outside_vn" {
  description = "This site is member of dc cluster group connected via outside network."
  type = object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  })
  default = null
}

#-----------------------------------------------------------
# Forward Proxy
#-----------------------------------------------------------

variable "active_forward_proxy_policies_list" {
  description = "List of Forward Proxy Policies."
  type = list(object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  }))
  default = []
}

variable "forward_proxy_allow_all" {
  description = "Enable Forward Proxy for this site and allow all requests."
  type        = bool
  default     = null
}

#-----------------------------------------------------------
# Global Network
#-----------------------------------------------------------

variable "global_network_connections_list" {
  description = "Global network connections."
  type = list(object({
    sli_to_global_dr = optional(object({
      global_vn  = object({
        name      = string
        namespace = optional(string)
        tenant    = optional(string)
      })
    }))
    slo_to_global_dr = optional(object({
      global_vn  = object({
        name      = string
        namespace = optional(string)
        tenant    = optional(string)
      })
    }))
  }))
  default = []
}

#-----------------------------------------------------------
# Static Routes
#-----------------------------------------------------------

variable "inside_static_route_list" {
  description = "List of Inside Static routes."
  type = list(object({
    custom_static_route = optional(object({
      attrs = optional(list(string))
      labels = optional(string)
      nexthop = optional(object({
        interface = optional(object({
          name      = string
          namespace = optional(string)
          tenant    = optional(string)
        }))
        nexthop_address = optional(object({
          ipv4 = optional(object({
            addr = optional(string)
          }))
          ipv6 = optional(object({
            addr = optional(string)
          }))
        }))
        type = optional(string)
      }))
      subnets = object({
        ipv4 = optional(object({
          plen   = optional(number)
          prefix = optional(string)
        }))
        ipv6 = optional(object({
          plen   = optional(number)
          prefix = optional(string)
        }))
      })
    }))
    simple_static_route = optional(string)
  }))
  default = []
}

variable "outside_static_route_list" {
  description = "List of Outside Static routes."
  type = list(object({
    custom_static_route = optional(object({
      attrs = optional(list(string))
      labels = optional(string)
      nexthop = optional(object({
        interface = optional(object({
          name      = string
          namespace = optional(string)
          tenant    = optional(string)
        }))
        nexthop_address = optional(object({
          ipv4 = optional(object({
            addr = optional(string)
          }))
          ipv6 = optional(object({
            addr = optional(string)
          }))
        }))
        type = optional(string)
      }))
      subnets = object({
        ipv4 = optional(object({
          plen   = optional(number)
          prefix = optional(string)
        }))
        ipv6 = optional(object({
          plen   = optional(number)
          prefix = optional(string)
        }))
      })
    }))
    simple_static_route = optional(string)
  }))
  default = []
}

#-----------------------------------------------------------
# Network Policies
#-----------------------------------------------------------

variable "enhanced_firewall_policies_list" {
  description = "Ordered List of Enhaned Firewall Policy active for this network firewall."
  type = list(object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  }))
  default = []
}

variable "active_network_policies_list" {
  description = "Ordered List of Firewall Policies active for this network firewall."
  type = list(object({
    name      = string
    namespace = optional(string)
    tenant    = optional(string)
  }))
  default = []
}

#-----------------------------------------------------------
# IP SEC
#-----------------------------------------------------------

variable "sm_connection_public_ip" {
  description = "Creating ipsec between two sites which are part of the site mesh group."
  type        = bool
  default     = true
}
 
# TODO: AWS TGW Settings
# default_storage
# storage_class_list 
# direct_connect_enabled
# direct_connect_disabled 

#-----------------------------------------------------------
# AWS VPC
#-----------------------------------------------------------

variable "vpc_instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_network_address_usage_metrics" {
  description = "Determines whether network address usage metrics are enabled for the VPC"
  type        = bool
  default     = null
}
