
resource "aws_key_pair" "private_ssh" {
  key_name   = "my-terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  security_groups = [aws_security_group.default_local_host_sg.name]
  key_name = aws_key_pair.private_ssh.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = file("userdata.sh")


  tags = {
    Name = var.instance_name
  }
}

resource "aws_security_group" "default_local_host_sg" {
  name        = "Default_local_host_sg"
  description = "Security group for SSH and HTTP from local host"


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

      tags = {
    Name = "EC2_Terraform"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "aws_secretsmanager_random_password" "pswd_generator" {
  password_length  = 50
  exclude_numbers = true
}

resource "aws_secretsmanager_secret" "my_secret_terraform" {
  name = var.secret_key
  description = "My secrted container from terraform"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "my_secret_value" {
  secret_id     = aws_secretsmanager_secret.my_secret_terraform.id
  secret_string = data.aws_secretsmanager_random_password.pswd_generator.random_password
}

resource "aws_iam_role" "ec2_extended_role" {

  name = "EC2SecretsAccessRole"
  assume_role_policy = file("ec2_role.json")
}

resource "aws_iam_policy" "extended_policy" {
  name        = "GeneralPolicyToEc2"
  description = "Policy to ec2 instance"

  policy = file("sm_access_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  policy_arn = aws_iam_policy.extended_policy.arn
  role       = aws_iam_role.ec2_extended_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2ExtendedInstanceProfile"
  role = aws_iam_role.ec2_extended_role.name
}

resource "aws_security_group" "lb_sg" {
  name        = "load-balancer-sg"
  description = "Security Group for Load Balancer"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name = "LB_Terraform"
  }
}


resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "AppLoadBalancer"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

    tags = {
    Name = "TG_Terraform"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 80
}

