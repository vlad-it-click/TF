#------------------------------------
#  build EC2 instance
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags { 
    tags = {
     CreatedBy = "Terraform"
    }
  }
}

resource "aws_instance" "EC2" {
    ami = "ami-0453ec754f44f9a4a"  # Amazon Linux AMI free tier
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mySG.id]

    tags = {
       Name = "MyEC2"
     }
}
#------------------------------------
#  Elastic IP declaration
#------------------------------------
resource "aws_eip" "myEIP" {
    instance = aws_instance.EC2.id
  
}

#------------------------------------
#  VPC declaration
#------------------------------------
resource "aws_default_vpc" "default" {}

#------------------------------------
#  security group
#------------------------------------
resource "aws_security_group" "mySG" {
    name = "HTTPS SG"

    tags = {
      Name = "Allow_HTTPS_IN"
     }

    ingress  {
          description = "Allow HTTPS from anywehere"
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress  {
         description = "Allow OUTgoing traffic to any"
         from_port = 0
         to_port = 0
         protocol = "-1"
         cidr_blocks = [ "0.0.0.0/0" ]
    }
}


output "MyEC2_EIP" {
  value = aws_eip.myEIP.public_ip
}

