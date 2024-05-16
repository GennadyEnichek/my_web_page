output "www-bucket-id" {
  value       = aws_s3_bucket.www-bucket.id
  description = "Provide www bucket ID"
}

output "www-bucket-arn" {
  value       = aws_s3_bucket.www-bucket.arn
  description = "Provide www bucket amazon resource name (ARN)"
}

output "www-bucket-domain" {
  value       = aws_s3_bucket_website_configuration.www-bucket-redirection.website_domain
  description = "Provide www bucket website domain name for Rout53 alias creation "
}

output "www-bucket-endpoint" {
  value       = aws_s3_bucket_website_configuration.www-bucket-redirection.website_endpoint
  description = "Provide www bucket endpoint"
}

output "www-bucket-hosted-zone-id" {
  value       = aws_s3_bucket.www-bucket.hosted_zone_id
  description = "Provide www bucket hosted zone ID"
}
