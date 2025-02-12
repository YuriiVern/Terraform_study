resource "aws_iam_role" "ec2_secrets_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerReadOnly"
  description = "Allows EC2 to read secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.ec2_secrets_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2SecretsInstanceProfile"
  role = aws_iam_role.ec2_secrets_role.name
}
