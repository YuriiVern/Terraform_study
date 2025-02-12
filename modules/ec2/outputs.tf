output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}


output "iam_instance_profile" {
  description = "IAM Instance EC2 Profile name"
  value = aws_instance.app_server.iam_instance_profile
}