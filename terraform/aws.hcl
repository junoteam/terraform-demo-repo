# Locals
locals {
  pwd         = path_relative_to_include()
  stack       = split("/", local.pwd)[2]
  region      = split("/", local.pwd)[1]
  aws_region  = local.region == "global" ? "us-east-1" : local.region
  environment = split("/", local.pwd)[0]
  cloud       = "aws"
  account_id  = get_aws_account_id()
}

# Terragrunt configuration
retry_max_attempts       = 5
retry_sleep_interval_sec = 60

# Versions constraints
terraform_version_constraint  = "~> 1.7.4"
terragrunt_version_constraint = "~> 0.55.16"

# Generate terraform files
generate "terraform-config" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
      required_version = "~> 1.7.4"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.40.0"
        }
      }
    }
  EOF
}

# Generate terraform files
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = ""
}

# AWS provider
generate "aws" {
  path      = "aws.auto.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
      default_tags {
        tags = {
          ManagedBy = "Terragrunt"
          Environment = "${local.environment}"
        }
      }
    }
  EOF
}

# Remote state
remote_state {
  backend = "s3"
  config = {
    region         = local.aws_region
    encrypt        = true
    bucket         = "${local.account_id}-${local.cloud}-${local.environment}-${local.region}-terragrunt-states"
    key            = "terragrunt/${local.region}/${local.stack}.tfstate"
    dynamodb_table = "${local.cloud}-${local.environment}-terragrunt-states"
  }
}

# Inputs per env
inputs = yamldecode(try(file("${local.environment}.yaml"), ""))
