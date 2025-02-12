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

module "aws_security_group" {
  source = "./modules/security-group"

}

module "iam" {
  source    = "./modules/iam"

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

module "aws_instance" {
  source = "./modules/ec2"
  security_groups = [module.aws_security_group.sg_id]
  iam_instance_profile = module.iam.iam_instance_profile
}

