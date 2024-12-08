#------------------------------------
#  Terraform multiple providers
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Provider = "Main AWS Provider #1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "west"
  default_tags {
    tags = {
      Provider = "Second AWS Provider #2"
    }
  }
}

resource "aws_instance" "mainEC2" {
  ami           = "ami-0453ec754f44f9a4a" # Amazon Linux AMI free tier
  instance_type = "t2.micro"
  tags = {
    Name = "Main AWS provider EC2"
  }
}

resource "aws_instance" "secondEC2" {
  ami           = "ami-061dd8b45bc7deb3d" # Amazon Linux 2 AMI free tier
  instance_type = "t2.micro"
  provider      = aws.west
  tags = {
    Name = "Second AWS provider EC2"
  }
}