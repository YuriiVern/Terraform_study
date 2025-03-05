resource "aws_db_instance" "myapp_db" {
 identifier              = "database-1"
  engine                 = "mysql"   
  engine_version         = "8.0"    
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20      
  storage_type           = "gp2"     
  username               = "admin"  
  password               = "Extend7000$"
  db_name                = "mydatabase"
  vpc_security_group_ids = ["sg-0e32a7ca1e06f5eee"] 
  db_subnet_group_name   = "default-vpc-0abbcc881d1be5367"  
  availability_zone      = "us-east-1b"  
  backup_retention_period = 1             
  multi_az              = false           
  deletion_protection   = false          
  skip_final_snapshot    = true
  apply_immediately      = true

  tags = {
    Name        = "database-1"
    Environment = "terraform"
  }

}



