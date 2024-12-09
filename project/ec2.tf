module "private_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "private-single-instance"

  instance_type          = "t2.micro"
  key_name               = "tf_test_us_east_1"
  monitoring             = false
  vpc_security_group_ids = [module.private_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "private subnet"
  }
}

module "public_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "public-single-instance"

  instance_type          = "t2.micro"
  key_name               = "tf_test_us_east_1"
  monitoring             = false
  vpc_security_group_ids = [module.public_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "public subnet"
  }
}