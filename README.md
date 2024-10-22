<!-- BEGIN_TF_DOCS -->
# AWS Resilience Hub Application

[AWS Resilience Hub](https://aws.amazon.com/blogs/aws/monitor-and-improve-your-application-resiliency-with-resilience-hub/) is a new AWS service designed to help you define, track, and manage the resilience of your applications. \
AWS Resilience Hub lets you define your RTO and RPO objectives for each of your applications. Then it assesses your application’s configuration to ensure it meets your requirements. It provides actionable recommendations and a resilience score to help you track your application’s resiliency progress over time.
This Terraform module contains AWS Resilience Hub resources.

The resources that make up the application tracked by [AWS Resilience Hub](https://aws.amazon.com/blogs/aws/monitor-and-improve-your-application-resiliency-with-resilience-hub) must be managed in a tfstate file that [exists in S3](https://www.terraform.io/language/settings/backends/s3). This is a requirement of the service. As such, the argument `s3_state_file_url` is required and must point to the tfstate file where the resources are managed.
If possible, our recommendation is to maintain your application deployment in the same [root module](https://www.terraform.io/docs/glossary#root-module) as the Resilience Hub app definition deployment. See our [basic example](https://github.com/aws-ia/terraform-aws-resiliencehub-app/tree/main/examples).

The `app-components` variable is an object list composed of the following schema:

```
list(object({
    app_component_name = string
    app_component_type = string
    resources = list(object({
      resource_name            = string
      resource_type            = string
      resource_identifier      = string
      resource_identifier_type = string
      resource_region          = string
    }))
  }))
```

A single app-component is composed of:

- `app_component_name` - a unique name for each app-component
- `app_component_type` - one of the supported app-component types, as listed in <https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html>
- `resources` - the list of resources to that are assessed together

Please refer to <https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html> for more details.

A single resources is composed of:

- `resource_name` - a unique name for each resource
- `resource_type` - one of the supported resource types, as listed in <https://docs.aws.amazon.com/resilience-hub/latest/userguide/AppComponent.grouping.html>
- `resource_identifier` - either an ARN or identifier, depends on the actual resources (some AWS resources don't support ARN, refer to docs)
- `resource_identifier_type` - either `Native` or `Arn`, should correspond with `resource_identifier`
- `resource_region` - the AWS region where the resource is deployed

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.21.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.additional_invoker_role_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.resilience_hub_full_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.resilience_hub_assessment_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.resilience_hub_additional_access_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.resilience_hub_assessment_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.resilience_hub_full_access_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [awscc_resiliencehub_app.app](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_app) | resource |
| [awscc_resiliencehub_resiliency_policy.policy](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/resiliencehub_resiliency_policy) | resource |
| [random_id.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_components"></a> [app\_components](#input\_app\_components) | The application's app-components, including its resources | <pre>list(object({<br>    app_component_name = string<br>    app_component_type = string<br>    resources          = list(object({<br>      resource_name            = string<br>      resource_type            = string<br>      resource_identifier      = string<br>      resource_identifier_type = string<br>      resource_region          = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The Application's name | `string` | n/a | yes |
| <a name="input_arh_role_name"></a> [arh\_role\_name](#input\_arh\_role\_name) | Defines the role to be used by Resilience Hub | `string` | n/a | yes |
| <a name="input_rpo"></a> [rpo](#input\_rpo) | RPO across all failure metrics | `number` | n/a | yes |
| <a name="input_rto"></a> [rto](#input\_rto) | RTO across all failure metrics | `number` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name containing the statefile | `string` | n/a | yes |
| <a name="input_s3_bucket_region"></a> [s3\_bucket\_region](#input\_s3\_bucket\_region) | S3 bucket region containing the statefile | `string` | n/a | yes |
| <a name="input_s3_state_file_path"></a> [s3\_state\_file\_path](#input\_s3\_state\_file\_path) | S3 bucket path containing the statefile, e.g - path/to/statefile.tf | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The application created |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The policy created |
<!-- END_TF_DOCS -->