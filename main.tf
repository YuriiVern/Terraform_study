terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

resource "aws_security_group" "default_local_host_sg" {
  name        = "default_local_host_sg"
  description = "Security group for SSH and HTTP from local host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_key_pair" "private_ssh" {
  key_name   = "my-terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_secretsmanager_random_password" "pswd_generator" {
  password_length  = 50
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "my_secret_terraform" {
  name = var.secret_key
  description = "My secrted container from terraform"
}

resource "aws_secretsmanager_secret_version" "my_secret_value" {
  secret_id     = aws_secretsmanager_secret.my_secret_terraform.id
  secret_string = data.aws_secretsmanager_random_password.pswd_generator.random_password
}


resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.default_local_host_sg.name]
  key_name = aws_key_pair.private_ssh.key_name

  user_data = file("userdata.sh")

  tags = {
    Name = var.instance_name
  }
}
