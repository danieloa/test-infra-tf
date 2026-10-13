output "platform_cluster_id" {
  description = "Platform EKS Cluster ID"
  value       = module.core.platform_cluster_id
}

output "platform_cluster_endpoint" {
  description = "Platform EKS Cluster Endpoint"
  value       = module.core.platform_cluster_endpoint
}

output "tekton_cluster_id" {
  description = "Tekton EKS Cluster ID"
  value       = module.core.tekton_cluster_id
}

output "tekton_cluster_endpoint" {
  description = "Tekton EKS Cluster Endpoint"
  value       = module.core.tekton_cluster_endpoint
}

output "private_bucket_ids" {
  description = "Map of private bucket IDs"
  value       = module.core.private_bucket_ids
}

output "private_bucket_arns" {
  description = "Map of private bucket ARNs"
  value       = module.core.private_bucket_arns
}

output "public_bucket_ids" {
  description = "Map of public bucket IDs"
  value       = module.core.public_bucket_ids
}

output "public_bucket_arns" {
  description = "Map of public bucket ARNs"
  value       = module.core.public_bucket_arns
}
