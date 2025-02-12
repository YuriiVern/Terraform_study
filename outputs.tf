output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.aws_instance.instance_public_ip
}

data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "iam_instance_profile" {
  description = "IAM Instance Profile name"
  value       = module.iam.iam_instance_profile
}

output "iam_instance_profile_ec2" {
  description = "IAM Instance Profile name"
  value       = module.aws_instance.iam_instance_profile
  }