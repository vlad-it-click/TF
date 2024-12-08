#------------------------------------
#  build AWS RDS
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags { 
    tags = {
     CreatedBy = "Terraform"
     Section = "RDS instance"
    }
  }
}

resource "aws_db_instance" "myRDS" {
  identifier           = "my-rds-terraform"
  allocated_storage    = 5
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  port                 = 3306
}