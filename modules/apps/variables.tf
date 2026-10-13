variable "customer" {
  description = "Customer name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "platform_cluster_id" {
  description = "Platform EKS Cluster ID"
  type        = string
  default     = ""
}

variable "platform_cluster_endpoint" {
  description = "Platform EKS Cluster Endpoint"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
