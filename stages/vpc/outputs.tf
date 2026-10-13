output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "platform_subnet_ids" {
  description = "List of platform private subnet IDs"
  value       = module.vpc.platform_subnet_ids
}

output "tekton_subnet_ids" {
  description = "List of tekton private subnet IDs"
  value       = module.vpc.tekton_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database private subnet IDs"
  value       = module.vpc.database_subnet_ids
}

output "eks_security_group_id" {
  description = "ID of the security group for EKS"
  value       = module.vpc.eks_security_group_id
}

output "database_security_group_id" {
  description = "ID of the security group for databases"
  value       = module.vpc.database_security_group_id
}

output "platform_nat_gateway_id" {
  description = "ID of the Platform NAT Gateway"
  value       = module.vpc.platform_nat_gateway_id
}

output "tekton_nat_gateway_id" {
  description = "ID of the Tekton NAT Gateway"
  value       = module.vpc.tekton_nat_gateway_id
}
