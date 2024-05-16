#Creates gj85.eu s3 bucket for host my card website

# Defines provider and backend configuration
# Terraform configurations
terraform {
  # At moment of file creating terraform version was 1.8.2
  required_version = ">=1.8.2, <2.0.0"
  # Set backend for terraform state file
  backend "s3" {
    bucket  = "gj-terraform-state-s3-524"
    key     = "my-web-card/host-bucket/terraform.tfstate"
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

# Create bucket for website host
resource "aws_s3_bucket" "host-bucket" {
  bucket = var.bucket-name
}

resource "aws_s3_bucket_public_access_block" "host-bucket-access" {
  bucket = aws_s3_bucket.host-bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "host-bucket-policy" {
  bucket     = aws_s3_bucket.host-bucket.id
  policy     = templatefile("../web_bucket_policy.json", { bucket = var.bucket-name })
  depends_on = [aws_s3_bucket_public_access_block.host-bucket-access]
}

resource "aws_s3_bucket_website_configuration" "host-bucket-website" {
  bucket = aws_s3_bucket.host-bucket.id

  index_document {
    suffix = var.index-file
  }

  error_document {
    key = var.error-file
  }
}
