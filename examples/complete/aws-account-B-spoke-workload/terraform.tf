#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

terraform {
  required_version = ">= 1.14.0"

  # Replace with your own remote backend configuration.
  # backend "s3" {
  #   bucket       = "<your-state-bucket>"
  #   key          = "devops-agent-spoke/<account-name>.tfstate"
  #   region       = "eu-west-2"
  #   encrypt      = true
  #   use_lockfile = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

# Targets the workload account where the cross-account role is created.
provider "aws" {
  region = var.aws_region
}
