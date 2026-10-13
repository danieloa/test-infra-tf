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
  description = "Whether to fetch Core outputs from remote state"
  type        = bool
  default     = true
}
