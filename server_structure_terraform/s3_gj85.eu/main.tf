#Creates gj85.eu s3 bucket for store my card website files. The files will be used with Cloudfront
# In order to get hashes in lock file for windows and linux run: terraform providers lock -platform=windows_amd64 -platform=linux_amd64

# Defines provider and backend configuration
terraform {
  # At moment of file creating terraform version was 1.8.2
  required_version = ">=1.8.2, <2.0.0"
  # Set backend for terraform state file
  backend "s3" {
    bucket  = "gj-terraform-state-s3-524"
    key     = "my-web-card/website-source-bucket/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # In a moment of the file creating the provider version was 5.49.0
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider region.
provider "aws" {
  region = "eu-north-1"
}

# Variable to define bucket name
locals {
  bucket_name = "gj85.eu"
}

# Create regular bucket
resource "aws_s3_bucket" "website_source" {
  bucket = local.bucket_name
}

# not need public access. Reading access wil be providet only from CloudFron distribution
resource "aws_s3_bucket_public_access_block" "website_source_access" {
  bucket                  = aws_s3_bucket.website_source.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# The resource required for CloudFront Origin Access Control (OAC)
# Bucket policy chould be added after ClourFront resource is created
resource "aws_s3_bucket_ownership_controls" "website_source_owner_control" {
  bucket = aws_s3_bucket.website_source.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# To be sure that encription is active
resource "aws_s3_bucket_server_side_encryption_configuration" "website_source_encription" {
  bucket = aws_s3_bucket.website_source.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # The default encription SSE-S3
    }
  }
}

resource "aws_s3_bucket_versioning" "website_source_versioning" {
  bucket = aws_s3_bucket.website_source.id
  versioning_configuration {
    status = "Enabled"
  }
}
