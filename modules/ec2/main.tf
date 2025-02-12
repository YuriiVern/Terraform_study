
resource "aws_key_pair" "private_ssh" {
  key_name   = "my-terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  security_groups = var.security_groups
  key_name = aws_key_pair.private_ssh.key_name
  iam_instance_profile = var.iam_instance_profile
  user_data = file("userdata.sh")

  tags = {
    Name = var.instance_name
  }
}