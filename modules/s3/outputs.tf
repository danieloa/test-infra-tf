output "id" {
  description = "The ID of the bucket"
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket" {
  description = "The bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}
