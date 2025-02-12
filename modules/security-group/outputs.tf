output "sg_id" {
  description = "Security Group ID"
  value       = aws_security_group.default_local_host_sg.name
}