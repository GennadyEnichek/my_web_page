output "host-bucket-id" {
  value       = aws_s3_bucket.host-bucket.id
  description = "Provide hosted bucket ID"
}

output "host-bucket-arn" {
  value       = aws_s3_bucket.host-bucket.arn
  description = "Provide host bucket amazon resource name (ARN)"
}

output "host-bucket-domain" {
  value       = aws_s3_bucket_website_configuration.host-bucket-website.website_domain
  description = "Provide host bucket website domain name for Rout53 alias creation "
}

output "host-bucket-endpoint" {
  value       = aws_s3_bucket_website_configuration.host-bucket-website.website_endpoint
  description = "Provide host bucket endpoint"
}

output "host-bucket-hosted-zone-id" {
  value       = aws_s3_bucket.host-bucket.hosted_zone_id
  description = "Provide host bucket endpoint"
}
