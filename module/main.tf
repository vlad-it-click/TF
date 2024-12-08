#------------------------------------
#  build EC2 instance (modules)
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags { 
    tags = {
     CreatedBy = "Terraform (Modules)"
    }
  }
}

module "ec2module" {
    source = "./ec2"
}

output "MainOutput" {
    value = module.ec2module.InsideModule
}
