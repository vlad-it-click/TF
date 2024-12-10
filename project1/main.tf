#------------------------------------
#  Terraform project 1
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Provider  = "AWS Provider"
      Region    = "N.Virginia (us-east-1)"
      CreatedBy = "Terraform"
    }
  }
}

# Getting information about AZs 
#------------------------------------------------------------
# data "aws_availability_zones" "availablezones" {}

# Getting information about the latest Amazon Linux 2 
#------------------------------------------------------------
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }
}

# create new vpc for this project 
#------------------------------------------------------------
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-project-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#  security groups
#------------------------------------

resource "aws_security_group" "private-web-sg" {
  name        = "Private Security Group"
  description = "My private Web Servers SecurityGroup"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name   = "allow_SSH_HTTP_HTTPS"
    Status = "Private SG"
  }

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public-web-sg" {
  name        = "Public Security Group"
  description = "My public Web Servers SecurityGroup"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name   = "allow_SSH_HTTP_HTTPS"
    Status = "Public SG"
  }

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#  Enable EC2 meta-data
#-------------------------------------------------------------
resource "aws_ec2_instance_metadata_defaults" "enforce-imdsv2" {
  http_tokens                 = "optional"
  http_put_response_hop_limit = 1
}

# Launch EC2 instance
#------------------------------------------------------------
resource "aws_instance" "private_webserver" {
  count                  = 1
  ami                    = data.aws_ami.latest_amazon_linux.id # Amazon Linux AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private-web-sg.id]
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = filebase64("${path.module}/user-data_private.sh")

  tags = {
    Name = "Private web server build by terraform"
  }
}

resource "aws_instance" "public_webserver" {
  count                  = 1
  ami                    = data.aws_ami.latest_amazon_linux.id # Amazon Linux AMI
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public-web-sg.id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = filebase64("${path.module}/user-data_public.sh")

  tags = {
    Name = "Public web server build by terraform"
  }
}



#  Outputs
#-----------------------

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "sg_id" {
  description = "SG ID"
  value       = aws_security_group.private-web-sg.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = module.vpc.private_subnets[0]
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = module.vpc.public_subnets[0]
}