#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# checkov:skip=CKV_*

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

locals {
  s3_state_file_url = "https://$BUCKET.s3.$BUCKET_REGION.amazonaws.com/$path/to/file.tfstate"
  app_name          = "Application-${random_string.session.id}"
  arh_role_name     = "ArhExecutorRole-${random_string.session.id}"
}

resource "random_string" "session" {
  length  = 8
  special = false
}

#tfsec:ignore:aws-dynamodb-enable-at-rest-encryption tfsec:ignore:aws-dynamodb-enable-recovery tfsec:ignore:aws-dynamodb-table-customer-key
resource "aws_dynamodb_table" "ddb_table" {
  billing_mode = "PAY_PER_REQUEST"
  name         = "DdbTable-${random_string.session.id}"

  hash_key = "key"
  attribute {
    name = "key"
    type = "N"
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "SqsQueue-${random_string.session.id}"
}

module "resiliencehub_app" {
  app_name = local.app_name
  source   = "../.."
  rto      = 300
  rpo      = 60
  app_components = [
    {
      app_component_name = "DynamoDBComponent"
      app_component_type = "AWS::ResilienceHub::DatabaseAppComponent"
      resources = [
        {
          resource_name            = "ddb_table"
          resource_type            = "AWS::DynamoDB::Table"
          resource_identifier      = aws_dynamodb_table.ddb_table.id
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    },
    {
      app_component_name = "SqsComponent"
      app_component_type = "AWS::ResilienceHub::QueueAppComponent"
      resources = [
        {
          resource_name            = "sqs_queue"
          resource_type            = "AWS::SQS::Queue"
          resource_identifier      = aws_sqs_queue.sqs_queue.id
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    }
  ]
  s3_state_file_url = local.s3_state_file_url
  arh_role_name = local.arh_role_name
}
