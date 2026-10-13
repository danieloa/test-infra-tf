variable "customer" {
  description = "Customer or project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to deploy subnets into"
  type        = list(string)
}

variable "product_domain" {
  description = "Domain name associated with the product"
  type        = string
  default     = ""
}

variable "company_ip" {
  description = "Company IP or CIDR block allowed to access EKS HTTPS endpoint"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
