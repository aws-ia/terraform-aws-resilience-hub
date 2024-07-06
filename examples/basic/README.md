<!-- BEGIN_TF_DOCS -->
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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resiliencehub_app"></a> [resiliencehub\_app](#module\_resiliencehub\_app) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name containing the statefile | `string` | n/a | yes |
| <a name="input_s3_bucket_region"></a> [s3\_bucket\_region](#input\_s3\_bucket\_region) | S3 bucket region containing the statefile | `string` | n/a | yes |
| <a name="input_s3_state_file_path"></a> [s3\_state\_file\_path](#input\_s3\_state\_file\_path) | S3 bucket path containing the statefile, e.g - path/to/statefile.tf | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->