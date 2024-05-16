
output "ns-records" {
  value       = aws_route53_zone.my-card-zone.name_servers
  description = "Output NS record for use it in other DNS provider"
}

