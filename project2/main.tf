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
data "aws_availability_zones" "availablezones" {}

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

# Launch templates for EC2
#------------------------------------------------------------

resource "aws_launch_template" "private-web" {
  name                   = "Private-WebServer"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private-web-sg.id]
  user_data              = filebase64("${path.module}/user-data_private.sh")

  tags = {
    Name   = "web server build from launch template"
    Status = "Private SG"
  }
}

resource "aws_launch_template" "public-web" {
  name                   = "Public-WebServer"
  image_id               = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.public-web-sg.id]
  user_data              = filebase64("${path.module}/user-data_public.sh")

  tags = {
    Name   = "web server build from launch template"
    Status = "Public SG"
  }
}

#  AutoScaling Groups
#---------------------------------------------------------------------

resource "aws_autoscaling_group" "private-web" {
  name                = "WebServer-Private-HA-ASG-Ver-${aws_launch_template.private-web.latest_version}"
  max_size            = 1
  min_size            = 1
  min_elb_capacity    = 1
  health_check_type   = "ELB"
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.private-web.arn]

  launch_template {
    id      = aws_launch_template.private-web.id
    version = aws_launch_template.private-web.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name   = "Private WebServer in ASG -v${aws_launch_template.private-web.latest_version}"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "public-web" {
  name                = "WebServer-Public-HA-ASG-Ver-${aws_launch_template.public-web.latest_version}"
  max_size            = 1
  min_size            = 1
  min_elb_capacity    = 1
  health_check_type   = "ELB"
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.public-web.arn]

  launch_template {
    id      = aws_launch_template.public-web.id
    version = aws_launch_template.public-web.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name   = "Public WebServer in ASG -v${aws_launch_template.public-web.latest_version}"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

#  Load Balancers
#-----------------------

resource "aws_lb" "private-web" {
  name               = "Private-WebServer-HA-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private-web-sg.id]
  subnets            = module.vpc.private_subnets

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb" "public-web" {
  name               = "Public-WebServer-HA-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public-web-sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Environment = "prod"
  }
}

#  Load Balancer Target Groups
#-------------------------------------------


resource "aws_lb_target_group" "private-web" {
  name                 = "Private-WebServer-HA-TG"
  vpc_id               = module.vpc.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10 #second
}

resource "aws_lb_listener" "private-http" {
  load_balancer_arn = aws_lb.private-web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private-web.arn
  }
}

resource "aws_lb_target_group" "public-web" {
  name                 = "Public-WebServer-HA-TG"
  vpc_id               = module.vpc.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 10 #second
}

resource "aws_lb_listener" "public-http" {
  load_balancer_arn = aws_lb.public-web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public-web.arn
  }
}

#  Outputs
#-----------------------

output "private_web_loadbalancer_url" {
  description = "The DNS name of the Private load balancer"
  value       = aws_lb.private-web.dns_name
}

output "public_web_loadbalancer_url" {
  description = "The DNS name of the Public load balancer"
  value       = aws_lb.public-web.dns_name
}
