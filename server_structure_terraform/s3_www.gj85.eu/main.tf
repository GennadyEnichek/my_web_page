
# Creates www.gj85.eu s3 bucket for redirection to gj85.eu


# Defines provider module and backend configuration
# Terraform configurations
terraform {
  # At moment of file creating terraform version was 1.8.2
  required_version = ">=1.8.2, <2.0.0"
  # Set backend for terraform state file
  backend "s3" {
    bucket  = "gj-terraform-state-s3-524"
    key     = "my-web-card/www-bucket/terraform.tfstate"
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

# Configure the AWS Provider For isolation reason the bucket will be created in different region.
provider "aws" {
  region = "eu-north-1"
}


# Creates bucket
resource "aws_s3_bucket" "www-bucket" {
  bucket = var.bucket-name

}

# Define access rules
resource "aws_s3_bucket_public_access_block" "gwww-bucket-access" {
  bucket = aws_s3_bucket.www-bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# Define access policy
resource "aws_s3_bucket_policy" "www-bucket-policy" {
  bucket     = aws_s3_bucket.www-bucket.id
  policy     = templatefile("../web_bucket_policy.json", { bucket = var.bucket-name })
  depends_on = [aws_s3_bucket_public_access_block.gwww-bucket-access]
}

#Defines the bucket as website and defines redirection to gj85.eu
resource "aws_s3_bucket_website_configuration" "www-bucket-redirection" {
  bucket = aws_s3_bucket.www-bucket.id

  redirect_all_requests_to {
    host_name = var.host-to-redirect
    protocol  = var.redirection-protocol
  }
}
