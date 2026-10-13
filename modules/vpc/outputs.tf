output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    for az_idx, az in var.availability_zones :
    aws_subnet.this["public-${az_idx}"].id
  ]
}

output "platform_subnet_ids" {
  description = "List of platform private subnet IDs"
  value = [
    for az_idx, az in var.availability_zones :
    aws_subnet.this["platform-${az_idx}"].id
  ]
}

output "tekton_subnet_ids" {
  description = "List of tekton private subnet IDs"
  value = [
    for az_idx, az in var.availability_zones :
    aws_subnet.this["tekton-${az_idx}"].id
  ]
}

output "database_subnet_ids" {
  description = "List of database private subnet IDs"
  value = [
    for az_idx, az in var.availability_zones :
    aws_subnet.this["database-${az_idx}"].id
  ]
}

output "eks_security_group_id" {
  description = "ID of the security group for EKS"
  value       = aws_security_group.eks.id
}

output "database_security_group_id" {
  description = "ID of the security group for databases"
  value       = aws_security_group.database.id
}

output "platform_nat_gateway_id" {
  description = "ID of the Platform NAT Gateway"
  value       = aws_nat_gateway.platform.id
}

output "tekton_nat_gateway_id" {
  description = "ID of the Tekton NAT Gateway"
  value       = aws_nat_gateway.tekton.id
}
