<!-- BEGIN_TF_DOCS -->
# EKS-Integrated Resilience Hub Application

This Terraform configuration sets up an EKS-integrated Resilience Hub application. It incorporates an EKS cluster with an automated Fargate profile and key Kubernetes resources for application deployment, directly tied into AWS Resilience Hub to manage resilience policies effectively. The setup includes configuring specific IAM roles and Kubernetes ConfigMaps to ensure proper permissions alignment as per [AWS Resilience Hub documentation](https://docs.aws.amazon.com/resilience-hub/latest/userguide/grant-permissions-to-eks-in-arh.html).

**Note:** the `main.tf` file contains replacement strings that need to be adjusted before deployment:

- `$BUCKET`, the S3 bucket for Terraform state storage
- `$path/to/file.tfstate`, the file path for the state file within the bucket
- `$BUCKET_REGION`, the AWS region where the S3 bucket is located

## App Components Configuration

The `app_components` configuration outlines how each part of the application is deployed and managed as a resilient component within AWS Resilience Hub:

```hcl
app_components = [
  {
    app_component_name = "EksDeploymentComponent"
    app_component_type = "AWS::ResilienceHub::ComputeAppComponent"
    resources          = [
      {
        # Must be the deployment name
        resource_name            = "app-2048"
        resource_type            = "AWS::EKS::Deployment"
        # Must be formatted as clusterArn/namespace/uid
        resource_identifier      = "${module.eks.cluster_arn}/${local.app_name}/${kubernetes_deployment_v1.this.metadata[0].uid}"
        resource_identifier_type = "Native"
        resource_region          = "us-west-2"
      }
    ]
  }
]
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.9 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.34 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.34 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.8 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.16 |
| <a name="module_resiliencehub_app"></a> [resiliencehub\_app](#module\_resiliencehub\_app) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.resilience_hub_eks_access_cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.resilience_hub_eks_access_cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [kubernetes_deployment_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [random_string.session](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->