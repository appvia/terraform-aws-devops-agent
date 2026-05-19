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
  #   key          = "agentspaces/<name>.tfstate"
  #   region       = "eu-west-2"
  #   encrypt      = true
  #   use_lockfile = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Targets the hosting account where the AgentSpace lives.
# IAM is global so aws_region is cosmetic here, but should match your primary region.
provider "aws" {
  region = var.aws_region
}

# The awscc provider MUST be configured to a supported AgentSpace region.
# eu-west-2 (London) is not a supported AgentSpace region.
# It must match var.agentspace_region passed to the module.
provider "awscc" {
  region = var.agentspace_region
}
