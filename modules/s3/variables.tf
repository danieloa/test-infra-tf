variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "is_public" {
  description = "Whether the bucket is intentionally public for assets"
  type        = bool
  default     = false
}

variable "with_cors" {
  description = "Whether to configure CORS rules for the bucket"
  type        = bool
  default     = false
}

variable "cors_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
