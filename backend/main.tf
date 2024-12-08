#------------------------------------
#  Terraform backend on S3
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags { 
    tags = {
     CreatedBy = "Terraform"
     Section = "S3 backend for terraform state"
    }
  }
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}
