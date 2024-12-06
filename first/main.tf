provider "aws" {
  region = "us-east-1"
}

variable "input_vpc_name" {
    type = string
    description = "plz input here your VPC name"    
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.input_vpc_name
  }
}

output "some_output_here" {
  value = aws_vpc.myvpc.id
}

