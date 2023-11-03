output "name" {
  description = "Name of the configured AWS VPC Site."
  value       = volterra_aws_vpc_site.this.name
}

output "id" {
  description = "ID of the configured AWS VPC Site."
  value       = volterra_aws_vpc_site.this.id
}

#-----------------------------------------------------
# SSH Key
#-----------------------------------------------------

output "ssh_private_key_pem" {
  description = "AWS VPC Site generated private key."
  value       = (null == var.ssh_key) ? tls_private_key.key.private_key_pem : null
  sensitive   = true
}

output "ssh_private_key_openssh" {
  description = "AWS VPC Site generated OpenSSH private key."
  value       = (null == var.ssh_key) ? tls_private_key.key.private_key_openssh : null
  sensitive   = true
}

output "ssh_public_key" {
  description = "AWS VPC Site public key."
  value       = coalesce(var.ssh_key, tls_private_key.key.public_key_openssh)
}

#-----------------------------------------------------
# AWS Site apply action output parameters
#-----------------------------------------------------

output "apply_tf_output" {
  description = "AWS Site apply terraform output parameter."
  value       = try(resource.volterra_tf_params_action.action_apply.tf_output, null)
}

output "apply_tf_output_map" {
  description = "AWS Site apply terraform output parameter."
  value       = try(local.output_map, null)
}

#-----------------------------------------------------
# AWS VPC Network output parameters
#-----------------------------------------------------

output "vpc_id" {
  value       = var.create_aws_vpc ? module.aws_vpc_network[0].vpc_id : var.vpc_id
  description = "The ID of the VPC."
}

output "vpc_cidr" {
  value       = var.create_aws_vpc ? module.aws_vpc_network[0].vpc_cidr : var.vpc_cidr
  description = "The CIDR block of the VPC."
}

output "outside_subnet_ids" {
  value       = local.outside_subnet_ids
  description = "The IDs of the outside subnets."
}

output "outside_route_table_ids" {
  value       = data.aws_route_table.outside_route_tables.*.id
  description = "The IDs of the outside route tables."
}

output "inside_subnet_ids" {
  value       = local.inside_subnet_ids
  description = "The IDs of the inside subnets."
}

output "inside_route_table_ids" {
  value       = data.aws_route_table.inside_route_tables.*.id
  description = "The IDs of the inside route tables."
}

output "workload_subnet_ids" {
  value       = local.workload_subnet_ids
  description = "The IDs of the workload subnets."
}

output "workload_route_table_ids" {
  value       = data.aws_route_table.workload_route_tables.*.id
  description = "The IDs of the workload route tables."
}

output "local_subnet_ids" {
  value       = local.local_subnet_ids
  description = "The IDs of the local subnets."
}

output "local_route_table_ids" {
  value       = data.aws_route_table.local_route_tables.*.id
  description = "The IDs of the local route tables."
}

output "internet_gateway_id" {
  value       = var.create_aws_vpc ? module.aws_vpc_network[0].internet_gateway_id : null
  description = "The ID of the internet gateway."
}

output "outside_security_group_id" {
  value       = (null != try(var.custom_security_group.outside_security_group_id, null)) ? var.custom_security_group.outside_security_group_id : (var.create_aws_vpc ? module.aws_vpc_network[0].outside_security_group_id : null)
  description = "The ID of the outside security group."
}
  
output "inside_security_group_id" {
  value       =  (null != try(var.custom_security_group.inside_security_group_id, null)) ? var.custom_security_group.inside_security_group_id : (var.create_aws_vpc ? module.aws_vpc_network[0].inside_security_group_id : null)
  description = "The ID of the inside security group."
}
