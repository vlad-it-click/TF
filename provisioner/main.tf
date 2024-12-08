#------------------------------------
#  Terraform using external provisioner
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Provider = "Main AWS Provider"
    }
  }
}

resource "aws_instance" "myEC2" {
  ami                    = "ami-0453ec754f44f9a4a" # Amazon Linux AMI free tier
  instance_type          = "t2.micro"
  key_name               = "tf_test_us_east_1"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nginx",
      "sudo systemctl start nginx"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./tf_test_us_east_1.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "My EC2 for provisioning"
  }

}

#------------------------------------
#  security group
#------------------------------------

resource "aws_security_group" "my_webserver" {
  name        = "Webserver Security Group"
  description = "My SG"

  tags = {
    Name = "allow_ssh_http"
  }

}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.my_webserver.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.my_webserver.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.my_webserver.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
