output "site_name" {
  description = "Name of the configured AWS VPC Site."
  value       = module.aws_vpc_site.name
}

output "site_id" {
  description = "ID of the configured AWS VPC Site."
  value       = module.aws_vpc_site.id
}

output "master_public_ip_address" {
  description = "Ip address of the master node."
  value       = try(module.aws_vpc_site.apply_tf_output_map.master_public_ip_address, null)
}

output "ssh_private_key" {
  description = "AWS VPC Site generated private key."
  value       = module.aws_vpc_site.ssh_private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "AWS VPC Site public key."
  value       = module.aws_vpc_site.ssh_public_key
}

output "vpc_id" {
  value       = module.aws_vpc_site.vpc_id
  description = "The ID of the VPC."
}

output "outside_subnet_ids" {
  value       = module.aws_vpc_site.outside_subnet_ids
  description = "The IDs of the outside subnets."
}

output "inside_subnet_ids" {
  value       = module.aws_vpc_site.inside_subnet_ids
  description = "The IDs of the inside subnets."
}

output "workload_subnet_ids" {
  value       = module.aws_vpc_site.workload_subnet_ids
  description = "The IDs of the workload subnets."
}

output "outside_security_group_id" {
  value       = module.aws_vpc_site.outside_security_group_id
  description = "The ID of the outside security group."
}
  
output "inside_security_group_id" {
  value       = module.aws_vpc_site.inside_security_group_id
  description = "The ID of the inside security group."
}

output "apply_tf_output_map" {
  description = "AWS Site apply terraform output parameter."
  value       = module.aws_vpc_site.apply_tf_output_map
}


output "outside_route_table_ids" {
  value       = module.aws_vpc_site.outside_route_table_ids
  description = "The IDs of the outside route tables."
}

output "inside_route_table_ids" {
  value       = module.aws_vpc_site.inside_route_table_ids
  description = "The IDs of the inside route tables."
}

output "workload_route_table_ids" {
  value       = module.aws_vpc_site.workload_route_table_ids
  description = "The IDs of the workload route tables."
}