terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = "admin"
}

resource "aws_iam_role" "ec2_limited_role" {
  name = "pd-ec2-limited-imdsv2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_limited_permissions" {
  name = "pd-ec2-limited-permissions"
  role = aws_iam_role.ec2_limited_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowIdentityCheck"
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowListBucketsOnly"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_instance_profile" "ec2_limited_profile" {
  name = "pd-ec2-limited-imdsv2-profile"
  role = aws_iam_role.ec2_limited_role.name
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_security_group" "imdsv2_lab_sg" {
  name        = "pd-imdsv2-lab-sg"
  description = "Security group for IMDSv2 workload identity lab"
  vpc_id      = data.aws_vpc.default.id

ingress {
    description = "Temporary SSH access from my current IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["139.216.77.109/32"]
}

  egress {
    description = "Allow outbound HTTPS for AWS API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pd-imdsv2-lab-sg"
  }
}
resource "aws_instance" "imdsv2_lab_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_limited_profile.name
  vpc_security_group_ids = [aws_security_group.imdsv2_lab_sg.id]
  key_name = "lab-key"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "pd-imdsv2-lab-instance"
  }
}
output "instance_public_ip" {
  value = aws_instance.imdsv2_lab_instance.public_ip
}

output "instance_id" {
  value = aws_instance.imdsv2_lab_instance.id
}