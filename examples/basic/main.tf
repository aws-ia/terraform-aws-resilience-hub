# checkov:skip=CKV_*

#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

locals {
  app_name           = "Application-${random_string.session.id}"
  arh_role_name      = "ArhExecutorRole-${random_string.session.id}"
}

resource "random_string" "session" {
  length  = 8
  special = false
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
          resource_identifier      = "DdbTable-IntegTest"
          resource_identifier_type = "Native"
          resource_region          = "us-east-1"
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
          resource_identifier      = "SqsQueue-IntegTest"
          resource_identifier_type = "Native"
          resource_region          = "us-west-2"
        }
      ]
    }
  ]
  s3_bucket_name     = var.s3_bucket_name
  s3_state_file_path = var.s3_state_file_path
  s3_bucket_region   = var.s3_bucket_region
  arh_role_name      = local.arh_role_name
}
