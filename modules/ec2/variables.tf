variable "instance_name" {
  description = "Terrafrom ec2 instance"
  type = string
  default = "Terraform ec2 instance"
}


variable "ami_id" {
  description = "ami id os for ec2"
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "security_groups" {
  description = "List of Security Group IDs for the instance"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile name"
  type        = string
}