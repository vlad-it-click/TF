#------------------------------------
#  Create new IAM user
#------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags { 
    tags = {
     CreatedBy = "Terraform"
    }
  }
}

resource "aws_iam_user" "newiamuser" {
    name = "test-user"
  }

resource "aws_iam_policy" "NewUserPolicy" {
    name = "Test-Custom-Policy"
    policy = <<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
EOF

}

resource "aws_iam_policy_attachment" "attachMyPolicy" {
    name = "attachment_policy"
    users = [aws_iam_user.newiamuser.name]
    policy_arn = aws_iam_policy.NewUserPolicy.arn
}
