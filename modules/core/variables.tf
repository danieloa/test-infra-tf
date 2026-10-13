variable "customer" {
  description = "Customer name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "product_domain" {
  description = "Product domain suffix for buckets"
  type        = string
}

variable "platform_subnet_ids" {
  description = "Subnet IDs for platform EKS cluster"
  type        = list(string)
}

variable "tekton_subnet_ids" {
  description = "Subnet IDs for tekton EKS cluster"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
