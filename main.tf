# checkov:skip=CKV_*

locals {
  s3_state_file_url = "https://${var.s3_bucket_name}.s3.${var.s3_bucket_region}.amazonaws.com/${var.s3_state_file_path}"
  statefile_name    = split("/", local.s3_state_file_url)[length(split("/", local.s3_state_file_url)) - 1]

  declared_app_components = [
    for app_component in var.app_components :
    {
      name          = app_component["app_component_name"]
      type          = app_component["app_component_type"]
      resourceNames = [
        for resource in app_component["resources"] :
        resource["resource_name"]
      ]
    }
  ]

  app_common_app_component = [
    {
      name = "appcommon"
      type = "AWS::ResilienceHub::AppCommonAppComponent",
      resourceNames : []
    }
  ]

  app_components = tolist(concat(local.declared_app_components, local.app_common_app_component))

  resources_list = flatten([
    for component in var.app_components : [
      for resource in component["resources"] : {
        resource_name            = resource["resource_name"]
        resource_type            = resource["resource_type"]
        resource_identifier_type = resource["resource_identifier_type"]
        resource_identifier      = resource["resource_identifier"]
        resource_region          = resource["resource_region"]
      }
    ]
  ])

  state_file_mapping = [
    {
      mapping_type = "Terraform"
      physical_resource_id = {
        identifier = local.s3_state_file_url
        type       = "Native"
      }
      terraform_source_name = local.statefile_name
    }
  ]

  eks_mappings_only = tolist(toset([
    for resource in local.resources_list :
    {
      mapping_type = "EKS"
      physical_resource_id = {
        # clusterArn/namespace
        identifier = join("/", slice(split("/", resource["resource_identifier"]), 0, 3))
        type       = "Arn"
        aws_region = resource["resource_region"]
      }
      # clusterName/namespace
      eks_source_name = join("/", slice(split("/", resource["resource_identifier"]), 1, 3))
    }
    if startswith(resource["resource_type"], "AWS::EKS")
  ]))

  resource_mappings = concat(local.eks_mappings_only, local.state_file_mapping)

  statefile_resources_json = [
    for resource in local.resources_list :
    {
      logicalResourceId = {
        identifier          = resource["resource_name"]
        terraformSourceName = local.statefile_name
      }
      physicalResourceId = {
        identifier = resource["resource_identifier"]
        awsRegion  = resource["resource_region"]
        type       = resource["resource_identifier_type"]
      }
      type = resource["resource_type"]
      name = resource["resource_name"]
    }
    if !startswith(resource["resource_type"], "AWS::EKS")
  ]

  eks_resources_json = [
    for resource in local.resources_list :
    {
      logicalResourceId = {
        # clusterName/namespace
        eksSourceName = join("/", slice(split("/", resource["resource_identifier"]), 1, 3))
        # resource_name must be the deployment/replica/pod name
        identifier = resource["resource_name"]
      }
      type = resource["resource_type"]
      name = resource["resource_name"]
    }
    if startswith(resource["resource_type"], "AWS::EKS")
  ]

  resources_json = concat(local.statefile_resources_json, local.eks_resources_json)
}

resource "random_id" "session" {
  byte_length = 16
}

resource "aws_iam_role" "resilience_hub_assessment_role" {
  name               = var.arh_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "resiliencehub.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resilience_hub_assessment_attachment" {
  role       = aws_iam_role.resilience_hub_assessment_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResilienceHubAsssessmentExecutionPolicy"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "resilience_hub_full_access_policy" {
  name        = "ResilienceHubFullAccessPolicy-${random_id.session.id}"
  description = "Policy granting full access to Resilience Hub"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Need in order to manage Resilience Hub resources
        Action   = "resiliencehub:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resilience_hub_full_access_attachment" {
  role       = aws_iam_role.resilience_hub_assessment_role.name
  policy_arn = aws_iam_policy.resilience_hub_full_access_policy.arn
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "additional_invoker_role_permissions" {
  name        = "AdditionalInvokerRolePermissions-${random_id.session.id}"
  description = "Policy granting additional permissions to InvokerRole"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # Need in order to be able to read statefiles for assessments
        Action   = "s3:GetObject"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resilience_hub_additional_access_attachment" {
  role       = aws_iam_role.resilience_hub_assessment_role.name
  policy_arn = aws_iam_policy.additional_invoker_role_permissions.arn
}

resource "awscc_resiliencehub_app" "app" {
  name              = var.app_name
  app_template_body = jsonencode({
    resources     = local.resources_json
    appComponents = local.app_components
    excludedResources = {}
    version       = 2
  })
  resource_mappings     = local.resource_mappings
  resiliency_policy_arn = awscc_resiliencehub_resiliency_policy.policy.policy_arn

  tags = {
    "terraform" = "managed"
  }

  permission_model = {
    type              = "RoleBased"
    invoker_role_name = var.arh_role_name
  }

  depends_on = [
    aws_iam_role.resilience_hub_assessment_role,
    awscc_resiliencehub_resiliency_policy.policy
  ]
}

resource "awscc_resiliencehub_resiliency_policy" "policy" {
  policy_name = "Policy-${random_id.session.id}"
  tier        = "MissionCritical"
  policy = {
    az = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    hardware = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    software = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
    region = {
      rto_in_secs = var.rto
      rpo_in_secs = var.rpo
    }
  }

  tags = {
    "terraform" = "managed"
  }
}