terraform {
  backend "s3" {
    key = "terraform/terraform.tfstate"
    bucket = "some-s3-bucket-name"
    region = "us-east-1"
    }
}