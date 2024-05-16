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

data "terraform_remote_state" "host-data" {
  backend = "s3"
  config = {
    bucket = "gj-terraform-state-s3-524"
    key    = "my-web-card/host-bucket/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "www-subdomain-data" {
  backend = "s3"
  config = {
    bucket = "gj-terraform-state-s3-524"
    key    = "my-web-card/www-bucket/terraform.tfstate"
    region = "eu-central-1"
  }
}

# Create AWS hosted zone. Zone name should be the same as domain name
resource "aws_route53_zone" "my-card-zone" {
  name       = var.hosted-zone-name
  depends_on = [data.terraform_remote_state.host-data, data.terraform_remote_state.www-subdomain-data]
}

# Alias record for host domain
resource "aws_route53_record" "host-record" {
  zone_id = aws_route53_zone.my-card-zone.zone_id
  name    = var.host-record-name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.host-data.outputs.host-bucket-domain         # host-bucket-domain
    zone_id                = data.terraform_remote_state.host-data.outputs.host-bucket-hosted-zone-id # host-bucket-hosted-zone-id
    evaluate_target_health = true
  }
}

# Alias record for www subdomain
resource "aws_route53_record" "www-record" {
  zone_id = aws_route53_zone.my-card-zone.zone_id
  name    = var.www-record-name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.www-subdomain-data.outputs.www-bucket-domain         # www-bucket-domain
    zone_id                = data.terraform_remote_state.www-subdomain-data.outputs.www-bucket-hosted-zone-id # www-bucket-hosted-zone-id
    evaluate_target_health = true
  }
}
