variable "config_file" {
  description = "Path or filename of the deployment configuration YAML inside deployment-configurations/"
  type        = string
  default     = "us-east-1_dev.yaml"
}

variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "use_remote_state" {
  description = "Whether to fetch VPC outputs from remote state"
  type        = bool
  default     = true
}

variable "override_platform_subnet_ids" {
  description = "Manual override for platform subnet IDs if use_remote_state is false"
  type        = list(string)
  default     = []
}

variable "override_tekton_subnet_ids" {
  description = "Manual override for tekton subnet IDs if use_remote_state is false"
  type        = list(string)
  default     = []
}
