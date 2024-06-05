output "my_card_distribution_id" {
  description = "The output represents AWS cloud distribution ID used for my-web-card"
  value       = aws_cloudfront_distribution.my_card_distribution.id
}

output "my_card_distribution_arn" {
  description = "The output represents AWS cloud distribution ARN used for my-web-card"
  value       = aws_cloudfront_distribution.my_card_distribution.arn
}

output "my_card_distribution_domain" {
  description = "The output represents default domain name for cloud distribution used for my-web-card"
  value       = aws_cloudfront_distribution.my_card_distribution.domain_name
}

output "my_card_distribution_hosted_zone_id" {
  description = "The output represents hosted zone ID for cloud distribution used for my-web-card to create Rout 53 record"
  value       = aws_cloudfront_distribution.my_card_distribution.hosted_zone_id
}
