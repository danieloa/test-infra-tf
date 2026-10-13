variable "config_file" {
  description = "Path or filename of the deployment configuration YAML inside deployment-configurations/"
  type        = string
  default     = "us-east-1_dev.yaml"
}

variable "aws_region" {
  description = "Target AWS Region (overrides default if specified)"
  type        = string
  default     = "us-east-1"
}
