# Defines provider module and backend configuration
# In order to get hashes in lock file for windows and linux run: terraform providers lock -platform=windows_amd64 -platform=linux_amd64
# Terraform configurations
terraform {
  # At moment of file creating terraform version was 1.8.2
  required_version = ">=1.8.2, <2.0.0"
  # Set backend for terraform state file
  backend "s3" {
    bucket  = "gj-terraform-state-s3-524"
    key     = "my-web-card/rout53/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
  # Set provider 
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # In a moment of the file creating the provider version was 5.49.0
      version = "~> 5.0"
    }
  }
}

locals {
  domain_name   = "gj85.eu"
  www_subdomain = "www.gj85.eu"
}

# Cloudfront distribution should be created before Rout 53 zone
data "terraform_remote_state" "website_distribution" {
  backend = "s3"
  config = {
    bucket = "gj-terraform-state-s3-524"
    key    = "my-web-card/website-cloudfront_distribution/terraform.tfstate"
    region = "eu-central-1"
  }
}

# Rout 53 zone already created with AWS console. So it is imported.
import {
  to = aws_route53_zone.my_web_card_zone
  id = "Z045110612PRK7QWKGG1D"
}

# Create AWS hosted zone. Zone name should be the same as domain name
resource "aws_route53_zone" "my_web_card_zone" {
  name    = local.domain_name
  comment = "The hosted zone used for manage my_web_card domain gj85.eu"
}

# Alias record for main domain
resource "aws_route53_record" "domain" {
  zone_id = aws_route53_zone.my_web_card_zone.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.website_distribution.outputs.my_card_distribution_domain         # domain name of cloudfront distribution
    zone_id                = data.terraform_remote_state.website_distribution.outputs.my_card_distribution_hosted_zone_id # cloudfront hosted zone id
    evaluate_target_health = true
  }

  depends_on = [data.terraform_remote_state.website_distribution]
}

# Alias record for www subdomain
resource "aws_route53_record" "www_subdomain" {
  zone_id = aws_route53_zone.my_web_card_zone.zone_id
  name    = local.www_subdomain
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.website_distribution.outputs.my_card_distribution_domain         # www-bucket-domain
    zone_id                = data.terraform_remote_state.website_distribution.outputs.my_card_distribution_hosted_zone_id # www-bucket-hosted-zone-id
    evaluate_target_health = true
  }

  depends_on = [data.terraform_remote_state.website_distribution]
}
