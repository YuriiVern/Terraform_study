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

resource "aws_iam_role" "ec2_secrets_role" {

  name = "EC2SecretsAccessRole"
  assume_role_policy = file("ec2_role.json")
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerReadOnly"
  description = "Allows EC2 to read secrets from AWS Secrets Manager"

  policy = file("sm_access_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.ec2_secrets_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2SecretsInstanceProfile"
  role = aws_iam_role.ec2_secrets_role.name
}

module "aws_instance" {
  source = "./modules/ec2"
  security_groups = [module.aws_security_group.sg_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

