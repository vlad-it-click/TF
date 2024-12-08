#------------------------------------
#  build EC2 instance (modules)
#------------------------------------

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "MyEC2" {
    ami = "ami-0453ec754f44f9a4a"  # Amazon Linux AMI free tier
    instance_type = "t2.micro"

    tags = {
       Name = "MyEC2 as a Module"
     }
}

output "InsideModule" {
    value = aws_instance.MyEC2.id
}
