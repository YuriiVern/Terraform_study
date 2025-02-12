output "iam_role_name" {
  description = "IAM Role name"
  value       = aws_iam_role.ec2_secrets_role.name
}

output "iam_instance_profile" {
  description = "IAM Instance Profile name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}
