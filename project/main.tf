#------------------------------------
#  Terraform project
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Provider = "AWS Provider"
      Region   = "N.Virginia (us-east-1)"
    }
  }
}

