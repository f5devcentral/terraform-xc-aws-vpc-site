locals {
  master_nodes_in_az_count = length(var.master_nodes_az_names)
  master_nodes_az_names    = var.master_nodes_az_names

  local_subnet_ids    = var.create_aws_vpc ? module.aws_vpc_network[0].local_subnet_ids : var.existing_local_subnets
  inside_subnet_ids   = var.create_aws_vpc ? module.aws_vpc_network[0].inside_subnet_ids : var.existing_inside_subnets
  outside_subnet_ids  = var.create_aws_vpc ? module.aws_vpc_network[0].outside_subnet_ids : var.existing_outside_subnets
  workload_subnet_ids = var.create_aws_vpc ? module.aws_vpc_network[0].workload_subnet_ids : var.existing_workload_subnets
}

#-----------------------------------------------------
# SSH Key
#-----------------------------------------------------

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#-----------------------------------------------------
# AWS VPC Network
#-----------------------------------------------------

module "aws_vpc_network" {
  count = var.create_aws_vpc ? 1 : 0

  source  = "f5devcentral/aws-vpc-site-networking/xc"
  version = "0.0.5"

  name             = format("%s-vpc", var.site_name)
  az_names         = var.master_nodes_az_names
  vpc_cidr         = var.vpc_cidr
  local_subnets    = var.local_subnets
  outside_subnets  = var.outside_subnets
  inside_subnets   = var.inside_subnets
  workload_subnets = var.workload_subnets


  vpc_instance_tenancy                     = var.vpc_instance_tenancy
  vpc_enable_dns_hostnames                 = var.vpc_enable_dns_hostnames
  vpc_enable_dns_support                   = var.vpc_enable_dns_support
  vpc_enable_network_address_usage_metrics = var.vpc_enable_network_address_usage_metrics
}

#-----------------------------------------------------
# XC AWS VPC Site
#-----------------------------------------------------

resource "volterra_aws_vpc_site" "this" {
  #-----------------------------------------------------
  # General Settings
  #-----------------------------------------------------

  name          = var.site_name
  description   = var.site_description
  namespace     = var.site_namespace

  os {
    default_os_version       = (null == var.operating_system_version)
    operating_system_version = (null != var.operating_system_version) ? var.operating_system_version : null
  }

  sw {
    default_sw_version        = (null == var.software_version)
    volterra_software_version = (null != var.software_version) ? var.software_version : null
  }

  offline_survivability_mode {
    enable_offline_survivability_mode = (true == var.offline_survivability_mode)
    no_offline_survivability_mode     = (true != var.offline_survivability_mode)
  }

  #-----------------------------------------------------
  # AWS
  #-----------------------------------------------------

  aws_region    = var.aws_region
  instance_type = var.instance_type
  disk_size     = var.nodes_disk_size
  tags          = var.tags

  aws_cred {
    name      = var.aws_cloud_credentials_name
    namespace = var.aws_cloud_credentials_namespace
    tenant    = var.aws_cloud_credentials_tenant
  }

  #-----------------------------------------------------
  # VPC
  #-----------------------------------------------------

  vpc {
    vpc_id = var.create_aws_vpc ? module.aws_vpc_network[0].vpc_id : var.vpc_id
  }

  #-----------------------------------------------------
  # Direct Connect
  #-----------------------------------------------------

  direct_connect_disabled = (null == var.direct_connect)
  dynamic direct_connect_enabled {
    for_each = (null != var.direct_connect) ? [0] : []

    content {
      auto_asn                     = var.direct_connect.auto_asn
      cloud_aggregated_prefix      = var.direct_connect.cloud_aggregated_prefix
      custom_asn                   = var.direct_connect.custom_asn
      dc_connect_aggregated_prefix = var.direct_connect.dc_connect_aggregated_prefix
    }
  }

  #-----------------------------------------------------
  # Egress
  #-----------------------------------------------------
  egress_gateway_default  = (null == var.egress_nat_gw && null == var.egress_virtual_private_gateway)

  dynamic egress_nat_gw {
    for_each = (null != var.egress_nat_gw) ? [0] : []

    content {
      nat_gw_id = var.egress_nat_gw.nat_gw_id
    }
  }

  dynamic egress_virtual_private_gateway {
    for_each = (null != var.egress_virtual_private_gateway) ? [0] : []

    content {
      vgw_id = var.egress_virtual_private_gateway.vgw_id
    }
  }

  #-----------------------------------------------------
  # Internet VIP
  #-----------------------------------------------------

  disable_internet_vip = (true != var.enable_internet_vip)
  enable_internet_vip  = (true == var.enable_internet_vip)

  #-----------------------------------------------------
  # Logs Streaming
  #-----------------------------------------------------

  logs_streaming_disabled = (null == var.log_receiver)

  dynamic log_receiver {
    for_each = null != var.log_receiver ? [0] : []

    content {
      name      = var.log_receiver.name
      namespace = var.log_receiver.namespace
      tenant    = vat.log_receiver.tenant
    }
  }

  #-----------------------------------------------------
  # SSH
  #-----------------------------------------------------

  ssh_key = coalesce(var.ssh_key, tls_private_key.key.public_key_openssh)

  #-----------------------------------------------------
  # Security Group
  #-----------------------------------------------------

  f5xc_security_group = (null == var.custom_security_group && !var.create_aws_vpc)

  dynamic custom_security_group {
    for_each = (null != var.custom_security_group || var.create_aws_vpc) ? [0] : []

    content {
      inside_security_group_id  = (null != try(var.custom_security_group.inside_security_group_id, null)) ? var.custom_security_group.inside_security_group_id : (var.create_aws_vpc ? module.aws_vpc_network[0].inside_security_group_id : null)
      outside_security_group_id = (null != try(var.custom_security_group.outside_security_group_id, null)) ? var.custom_security_group.outside_security_group_id : (var.create_aws_vpc ? module.aws_vpc_network[0].outside_security_group_id : null)
    }
  }

  #-----------------------------------------------------
  # Worker Nodes
  #-----------------------------------------------------

  no_worker_nodes = (0 == var.worker_nodes_per_az)
  nodes_per_az    = (0 < var.worker_nodes_per_az) ? var.worker_nodes_per_az : null

  #-----------------------------------------------------
  # Blocked Services
  #-----------------------------------------------------

  default_blocked_services = (true != var.block_all_services && null == var.blocked_service)
  block_all_services       = var.block_all_services

  dynamic blocked_services {
    for_each = (null != var.blocked_service && true != var.block_all_services) ? [0] : []

    content {
      blocked_sevice {
        dns                = var.blocked_service.dns
        ssh                = var.blocked_service.ssh
        web_user_interface = var.blocked_service.web_user_interface
        network_type       = var.blocked_service.network_type
      }
    }
  }

  #-----------------------------------------------------
  # Site type: Ingress Gateway
  #-----------------------------------------------------

  dynamic ingress_gw {
    for_each = var.site_type == "ingress_gw" ? [0] : []

    content {
      aws_certified_hw = "aws-byol-voltmesh"

      allowed_vip_port {
        dynamic "custom_ports" {
          for_each = (null != var.allowed_vip_port.custom_port_ranges) ? [0] : []
          content {
            port_ranges = var.allowed_vip_port.custom_port_ranges
          }
        }
        disable_allowed_vip_port = (true == var.allowed_vip_port.disable_allowed_vip_port)
        use_http_https_port      = (true == var.allowed_vip_port.use_http_https_port) ? true : null
        use_http_port            = (true == var.allowed_vip_port.use_http_port) ? true : null
        use_https_port           = (true == var.allowed_vip_port.use_https_port) ? true : null
      }

      dynamic az_nodes {
        for_each = { for idx, value in slice(local.master_nodes_az_names, 0, local.master_nodes_in_az_count) : tostring(idx) => value }

        content {
          aws_az_name = az_nodes.value

          local_subnet {
            existing_subnet_id = local.local_subnet_ids[tonumber(az_nodes.key)]
          }
        }
      }
      performance_enhancement_mode {
        perf_mode_l7_enhanced = (null == var.jumbo)

        dynamic perf_mode_l3_enhanced {
          for_each = (null != var.jumbo) ? [0] : []
          content {
            jumbo    = (true == var.jumbo) ? true : null
            no_jumbo = (false == var.jumbo) ? true : null
          }
        }
      }
    }
  }

  #-----------------------------------------------------
  # Ingress Egress Gateway
  #-----------------------------------------------------
  dynamic ingress_egress_gw  {
    for_each = var.site_type == "ingress_egress_gw" ? [0] : []

    content {
      aws_certified_hw = "aws-byol-multi-nic-voltmesh"

      allowed_vip_port {
        dynamic "custom_ports" {
          for_each = (null != var.allowed_vip_port.custom_port_ranges)  ? [0] : []
          content {
            port_ranges = var.allowed_vip_port.custom_port_ranges
          }
        }
        disable_allowed_vip_port = (true == var.allowed_vip_port.disable_allowed_vip_port)
        use_http_https_port      = (true == var.allowed_vip_port.use_http_https_port) ? true : null
        use_http_port            = (true == var.allowed_vip_port.use_http_port) ? true : null
        use_https_port           = (true == var.allowed_vip_port.use_https_port) ? true : null
      }

      allowed_vip_port_sli {
        dynamic "custom_ports" {
          for_each = (null != var.allowed_vip_port.custom_port_ranges)  ? [0] : []
          content {
            port_ranges = var.allowed_vip_port.custom_port_ranges
          }
        }
        disable_allowed_vip_port = (true == var.allowed_vip_port.disable_allowed_vip_port)
        use_http_https_port      = (true == var.allowed_vip_port.use_http_https_port) ? true : null
        use_http_port            = (true == var.allowed_vip_port.use_http_port) ? true : null
        use_https_port           = (true == var.allowed_vip_port.use_https_port) ? true : null
      }

      dynamic az_nodes {
        for_each = { for idx, value in slice(local.master_nodes_az_names, 0, local.master_nodes_in_az_count) : tostring(idx) => value }

        content {
          aws_az_name = az_nodes.value

          inside_subnet {
            existing_subnet_id = local.inside_subnet_ids[tonumber(az_nodes.key)]
          }

          outside_subnet {
            existing_subnet_id = local.outside_subnet_ids[tonumber(az_nodes.key)]
          }

          workload_subnet {
            existing_subnet_id = local.workload_subnet_ids[tonumber(az_nodes.key)]
          }
        }
      }

      #-----------------------------------------------------
      # DC Cluster Group
      #-----------------------------------------------------

      no_dc_cluster_group = (null == var.dc_cluster_group_inside_vn && null == var.dc_cluster_group_outside_vn)

      dynamic dc_cluster_group_inside_vn {
        for_each = (null != var.dc_cluster_group_inside_vn) ? [0] : []

        content {
          name      = var.dc_cluster_group_inside_vn.name
          namespace = var.dc_cluster_group_inside_vn.namespace
          tenant    = var.dc_cluster_group_inside_vn.tenant
        }
      }

      dynamic dc_cluster_group_outside_vn {
        for_each = (null != var.dc_cluster_group_outside_vn) ? [0] : []

        content {
          name      = var.dc_cluster_group_outside_vn.name
          namespace = var.dc_cluster_group_outside_vn.namespace
          tenant    = var.dc_cluster_group_outside_vn.tenant
        }
      }

      #-----------------------------------------------------
      # Global Network
      #-----------------------------------------------------

      no_global_network = (length(var.global_network_connections_list) == 0)

      dynamic global_network_list {
        for_each = (length(var.global_network_connections_list) > 0) ? [0] : []

        content {
          dynamic "global_network_connections" {
            for_each = var.global_network_connections_list
            content {
              dynamic "sli_to_global_dr" {
                for_each = (null != global_network_connections.value.sli_to_global_dr) ? [0] : []

                content {
                  global_vn {
                    name      = global_network_connections.value.sli_to_global_dr.global_vn.name
                    namespace = global_network_connections.value.sli_to_global_dr.global_vn.namespace
                    tenant    = global_network_connections.value.sli_to_global_dr.global_vn.tenant
                  }
                }
              }

              dynamic "slo_to_global_dr" {
                for_each = (null != global_network_connections.value.slo_to_global_dr) ? [0] : []

                content {
                  global_vn {
                    name      = global_network_connections.value.slo_to_global_dr.global_vn.name
                    namespace = global_network_connections.value.slo_to_global_dr.global_vn.namespace
                    tenant    = global_network_connections.value.slo_to_global_dr.global_vn.tenant
                  }
                }
              }
            }
          }
        }
      }

      #-----------------------------------------------------
      # Static Routes
      #-----------------------------------------------------

      no_inside_static_routes  = (length(var.inside_static_route_list) == 0)

      dynamic "inside_static_routes" {
        for_each = (length(var.inside_static_route_list) > 0) ? [0] : []
        content {
          dynamic "static_route_list" {
            for_each = var.inside_static_route_list
            content {
              simple_static_route = static_route_list.value.simple_static_route
              dynamic "custom_static_route" {
                for_each = (null != static_route_list.value.custom_static_route) ? [0] : []
                content {
                  attrs = static_route_list.value.custom_static_route.attrs
                  labels = static_route_list.value.custom_static_route.labels

                  dynamic "nexthop" {
                    for_each = (null != static_route_list.value.custom_static_route.nexthop) ? [0] : []
                    content {
                      type = static_route_list.value.custom_static_route.nexthop.type

                      dynamic "interface" {
                        for_each = (null != static_route_list.value.custom_static_route.nexthop.interface) ? [0] : []
                        content {
                          name = static_route_list.value.custom_static_route.nexthop.interface.name
                          namespace = static_route_list.value.custom_static_route.nexthop.interface.namespace
                          tenant = static_route_list.value.custom_static_route.nexthop.interface.tenant
                        }
                      }

                      dynamic "nexthop_address" {
                        for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address) ? [0] : []
                        content {
                          dynamic "ipv4" {
                            for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv4) ? [0] : []
                            content {
                              addr = static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv4.addr
                            }
                          }
                          dynamic "ipv6" {
                            for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv6) ? [0] : []
                            content {
                              addr = static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv6.addr
                            }
                          }
                        }
                      }
                    }
                  }

                  dynamic "subnets" {
                    for_each = (null != static_route_list.value.custom_static_route.subnets) ? [0] : []
                    content {
                      dynamic "ipv4" {
                        for_each = (null != static_route_list.value.custom_static_route.subnets.ipv4) ? [0] : []
                        content {
                          plen  = static_route_list.value.custom_static_route.subnets.ipv4.plen
                          prefix = static_route_list.value.custom_static_route.subnets.ipv4.prefix
                        }
                      }
                      dynamic "ipv6" {
                        for_each = (null != static_route_list.value.custom_static_route.subnets.ipv6) ? [0] : []
                        content {
                          plen  = static_route_list.value.custom_static_route.subnets.ipv6.plen
                          prefix = static_route_list.value.custom_static_route.subnets.ipv6.prefix
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      no_outside_static_routes = (length(var.outside_static_route_list) == 0)

      dynamic "outside_static_routes" {
        for_each = (length(var.outside_static_route_list) > 0) ? [0] : []
        content {
          dynamic "static_route_list" {
            for_each = var.outside_static_route_list
            content {
              simple_static_route = static_route_list.value.simple_static_route
              dynamic "custom_static_route" {
                for_each = (null != static_route_list.value.custom_static_route) ? [0] : []
                content {
                  attrs = static_route_list.value.custom_static_route.attrs
                  labels = static_route_list.value.custom_static_route.labels

                  dynamic "nexthop" {
                    for_each = (null != static_route_list.value.custom_static_route.nexthop) ? [0] : []
                    content {
                      type = static_route_list.value.custom_static_route.nexthop.type

                      dynamic "interface" {
                        for_each = (null != static_route_list.value.custom_static_route.nexthop.interface) ? [0] : []
                        content {
                          name = static_route_list.value.custom_static_route.nexthop.interface.name
                          namespace = static_route_list.value.custom_static_route.nexthop.interface.namespace
                          tenant = static_route_list.value.custom_static_route.nexthop.interface.tenant
                        }
                      }

                      dynamic "nexthop_address" {
                        for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address) ? [0] : []
                        content {
                          dynamic "ipv4" {
                            for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv4) ? [0] : []
                            content {
                              addr = static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv4.addr
                            }
                          }
                          dynamic "ipv6" {
                            for_each = (null != static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv6) ? [0] : []
                            content {
                              addr = static_route_list.value.custom_static_route.nexthop.nexthop_address.ipv6.addr
                            }
                          }
                        }
                      }
                    }
                  }
                  dynamic "subnets" {
                    for_each = (null != static_route_list.value.custom_static_route.subnets) ? [0] : []
                    content {
                      dynamic "ipv4" {
                        for_each = (null != static_route_list.value.custom_static_route.subnets.ipv4) ? [0] : []
                        content {
                          plen  = static_route_list.value.custom_static_route.subnets.ipv4.plen
                          prefix = static_route_list.value.custom_static_route.subnets.ipv4.prefix
                        }
                      }
                      dynamic "ipv6" {
                        for_each = (null != static_route_list.value.custom_static_route.subnets.ipv6) ? [0] : []
                        content {
                          plen  = static_route_list.value.custom_static_route.subnets.ipv6.plen
                          prefix = static_route_list.value.custom_static_route.subnets.ipv6.prefix
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      #-----------------------------------------------------
      # Manage Firewall Policy
      #-----------------------------------------------------

      no_network_policy = (length(var.enhanced_firewall_policies_list) == 0 && length(var.active_network_policies_list) == 0)

      dynamic "active_enhanced_firewall_policies" {
        for_each = (length(var.enhanced_firewall_policies_list) > 0) ? [0] : []
        content {
          dynamic "enhanced_firewall_policies" {
            for_each = var.enhanced_firewall_policies_list
            content {
              name      = enhanced_firewall_policies.value.name
              namespace = enhanced_firewall_policies.value.namespace
              tenant    = enhanced_firewall_policies.value.tenant
            }
          }

        }
      }

      dynamic "active_network_policies" {
        for_each = (length(var.active_network_policies_list) > 0) ? [0] : []
        content {
          dynamic "network_policies" {
            for_each = var.active_network_policies_list
            content {
              name      = network_policies.value.name
              namespace = network_policies.value.namespace
              tenant    = network_policies.value.tenant
            }
          }

        }
      }

      #-----------------------------------------------------
      # Manage Forward Proxy
      #-----------------------------------------------------

      no_forward_proxy = (length(var.active_forward_proxy_policies_list) == 0)

      forward_proxy_allow_all = (true == var.forward_proxy_allow_all)

      dynamic "active_forward_proxy_policies" {
        for_each = (length(var.active_forward_proxy_policies_list) > 0) ? [0] : []
        content {
          dynamic "forward_proxy_policies" {
            for_each = var.active_forward_proxy_policies_list
            content {
              name      = enhanced_firewall_policies.value.name
              namespace = enhanced_firewall_policies.value.namespace
              tenant    = enhanced_firewall_policies.value.tenant
            }
          }

        }
      }

      #-----------------------------------------------------
      # IP SEC
      #-----------------------------------------------------

      sm_connection_public_ip  = (true == var.sm_connection_public_ip)
      sm_connection_pvt_ip     = (true != var.sm_connection_public_ip)

      #-----------------------------------------------------
      # Performance Mode
      #-----------------------------------------------------

      performance_enhancement_mode {
        perf_mode_l7_enhanced = (null == var.jumbo)

        dynamic perf_mode_l3_enhanced {
          for_each = (null != var.jumbo) ? [0] : []
          content {
            jumbo    = (true == var.jumbo) ? true : null
            no_jumbo = (false == var.jumbo) ? true : null
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.this.name
  site_type        = "aws_vpc_site"
  labels           = var.tags
  ignore_on_delete = true

  depends_on = [
    volterra_aws_vpc_site.this
  ]
}

resource "volterra_tf_params_action" "action_apply" {
  site_name        = volterra_aws_vpc_site.this.name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = var.apply_action_wait_for_action
  ignore_on_update = var.apply_action_ignore_on_update

  depends_on = [
    volterra_aws_vpc_site.this
  ]
}

locals {
  tf_output = resource.volterra_tf_params_action.action_apply.tf_output
  lines = split("\n", trimspace(local.tf_output))
  output_map = { 
    for line in local.lines :
      trimspace(element(split("=", line), 0)) => jsondecode(trimspace(element(split("=", line), 1)))
    if can(regex("=", line))
  }
}

data "aws_route_table" "local_route_tables" {
  count = length(local.local_subnet_ids)

  subnet_id = element(local.local_subnet_ids, count.index)
  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

data "aws_route_table" "inside_route_tables" {
  count = length(local.inside_subnet_ids)

  subnet_id = element(local.inside_subnet_ids, count.index)
  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

data "aws_route_table" "workload_route_tables" {
  count = length(local.workload_subnet_ids)

  subnet_id = element(local.workload_subnet_ids, count.index)
  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}

data "aws_route_table" "outside_route_tables" {
  count = length(local.outside_subnet_ids)

  subnet_id = element(local.outside_subnet_ids, count.index)
  depends_on = [
    volterra_tf_params_action.action_apply
  ]
}
