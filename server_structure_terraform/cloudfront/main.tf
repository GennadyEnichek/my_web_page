# Defines provider module and backend configuration
# In order to get hashes in lock file for windows and linux run: terraform providers lock -platform=windows_amd64 -platform=linux_amd64
# Terraform configurations
terraform {
  # At moment of file creating terraform version was 1.8.2
  required_version = ">=1.8.2, <2.0.0"
  # Set backend for terraform state file
  backend "s3" {
    bucket  = "gj-terraform-state-s3-524"
    key     = "my-web-card/website-cloudfront_distribution/terraform.tfstate"
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

# Configure the AWS Provider to find Amazon TLS Certificate.
provider "aws" {
  region = "us-east-1"
  alias  = "acm_region"
}

# At first should be created s3 bucket as web page source
data "terraform_remote_state" "website_source" {
  backend = "s3"
  config = {
    bucket = "gj-terraform-state-s3-524"
    key    = "my-web-card/website-source-bucket/terraform.tfstate"
    region = "eu-central-1"
  }
}

# find the SSL/TLS certificate in Amazon Certificate Manager
data "aws_acm_certificate" "tls_certificat_for_my_web_card" {
  domain      = "gj85.eu"
  most_recent = true
  provider    = aws.acm_region
}

locals {
  my_card_origin_id = "my-card-origin"
  casch_policy_id   = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # the policy do not allow cash
}

# The resource prevent communication with s3 from outside, only reachable from CloudFront https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
resource "aws_cloudfront_origin_access_control" "origin_access" {
  name                              = "my-website-oac"
  description                       = "Access policy for my-card project s3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Creation of resource CloudFront
resource "aws_cloudfront_distribution" "my_card_distribution" {
  enabled             = true                                                                        # Required. Accepts user requests.
  is_ipv6_enabled     = true                                                                        # Optional. Whether the IPv6 is enabled for the distribution
  comment             = "The distribution created to make safety connection to s3 my-card website " # Optional
  default_root_object = "index.html"                                                                # Optional defines, what s3 object will requested for root URL. Other object could be reached address/object
  aliases             = ["gj85.eu", "www.gj85.eu"]                                                  # alternative domain names. Later sholud be added to Route53
  price_class         = "PriceClass_100"

  # Origin section defines the AWS resource to be requested (and how to be requested) for content.
  origin {
    domain_name              = data.terraform_remote_state.website_source.outputs.source_bucket_regional_domain # the domain name of the s3 bucket
    origin_id                = local.my_card_origin_id                                                          # the way to recognize the origin
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access.id
    connection_attempts      = 3
    connection_timeout       = 10

    # origin_shield {
    #  enabled = false
    # }
  }

  # Caching behaviour
  default_cache_behavior {
    target_origin_id       = local.my_card_origin_id # define the origin to applay the behaviour 
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cache_policy_id        = local.casch_policy_id
    cached_methods         = ["GET", "HEAD"]
    compress               = false
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.aws_acm_certificate.tls_certificat_for_my_web_card.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  # No any restriction
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }

  depends_on = [data.terraform_remote_state.website_source] # at first s3 bucket should be created
}

# after creation of cloud front distribution, update source bucket policy
resource "aws_s3_bucket_policy" "source_policy_for_distribution_oac" {
  bucket = data.terraform_remote_state.website_source.outputs.source_bucket_id
  policy = templatefile("./source_bucket_policy.json", { bucket_arn = data.terraform_remote_state.website_source.outputs.source_bucket_arn, distribution_arn = aws_cloudfront_distribution.my_card_distribution.arn })

  depends_on = [aws_cloudfront_distribution.my_card_distribution]
}
