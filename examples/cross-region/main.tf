#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# checkov:skip=CKV_*

locals {
  s3_bucket_name     = "yalevy-terraform"
  s3_state_file_path = "cross-region.tfstate"
  s3_bucket_region   = "us-west-2"
  app_name           = "Application-${random_string.session.id}"
  arh_role_name      = "ArhExecutorRole-${random_string.session.id}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "$BUCKET"
    key    = "$path/to/file.tfstate"
    region = "$BUCKET_REGION"
  }
}

resource "random_string" "session" {
  length  = 8
  special = false
}

module "use1" {
  source = "./use1"
}

module "use2" {
  source = "./use2"
}

module "resiliencehub_app" {
  app_name       = local.app_name
  source         = "../.."
  rto            = 300
  rpo            = 60
  app_components = [
    {
      app_component_name = "CrossRegionAsgComponent"
      app_component_type = "AWS::ResilienceHub::ComputeAppComponent"
      resources          = [
        {
          resource_name            = "Use1Asg"
          resource_type            = "AWS::AutoScaling::AutoScalingGroup"
          resource_identifier      = module.use1.asg_id
          resource_identifier_type = "Native"
          resource_region          = "us-east-1"
        },
        {
          resource_name            = "Use2Asg"
          resource_type            = "AWS::AutoScaling::AutoScalingGroup"
          resource_identifier      = module.use2.asg_id
          resource_identifier_type = "Native"
          resource_region          = "us-east-2"
        },
      ]
    },
  ]
  s3_bucket_name     = local.s3_bucket_name
  s3_state_file_path = local.s3_state_file_path
  s3_bucket_region   = local.s3_bucket_region
  arh_role_name      = local.arh_role_name
}
