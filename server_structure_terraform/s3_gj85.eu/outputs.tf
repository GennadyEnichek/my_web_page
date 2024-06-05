output "source_bucket_id" {
  value       = aws_s3_bucket.website_source.id
  description = "Output of website source bucket ID"
}

output "source_bucket_arn" {
  value       = aws_s3_bucket.website_source.arn
  description = "Output of website source bucket amazon resource name (ARN)"
}

output "source_bucket_domain" {
  value       = aws_s3_bucket.website_source.bucket_domain_name
  description = "Output of website source bucket domain name "
}

output "source_bucket_regional_domain" {
  value       = aws_s3_bucket.website_source.bucket_regional_domain_name
  description = "Output ofwebsite source bucket regional domain name as origin source for CloudFront"
}

