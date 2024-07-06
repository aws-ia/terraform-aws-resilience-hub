variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name containing the statefile"
}

variable "s3_bucket_region" {
  type        = string
  description = "S3 bucket region containing the statefile"
}

variable "s3_state_file_path" {
  type        = string
  description = "S3 bucket path containing the statefile, e.g - path/to/statefile.tf"
}