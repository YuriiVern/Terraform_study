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

variable "secret_key" {
  description = "secret key that used to get value"
  type = string
  default = "my-test-secret_v1"
}