# checkov:skip=CKV_*

# tfsec:ignore:custom-custom-cus002 tfsec:ignore:aws-autoscaling-enforce-http-token-imds tfsec:ignore:aws-autoscaling-enable-at-rest-encryption tfsec:ignore:custom-custom-cus003
resource "aws_launch_configuration" "launch_conf_use2" {
  name_prefix   = "terraform-lc"
  image_id      = data.aws_ami.al2_use2.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
  provider = aws.use2
}

resource "aws_autoscaling_group" "autoscaling_group_use2" {
  name                 = "terraform-asg"
  availability_zones   = ["us-east-2a"]
  launch_configuration = aws_launch_configuration.launch_conf_use2.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
  provider = aws.use2
}