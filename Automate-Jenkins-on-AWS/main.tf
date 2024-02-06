# main.tf
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # AWS Canonical account ID for Ubuntu
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
# Generate tls_private_key
resource "tls_private_key" "jenkins_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
# Save the private key to a local file
resource "local_file" "private_key_file" {
  content  = tls_private_key.jenkins_key_pair.private_key_pem
  filename = "jenkins_private_key.pem"
  provisioner "local-exec" {
    command = "chmod 400 ${path.module}/jenkins_private_key.pem"
  }
}
# Create a default VPC
resource "aws_default_vpc" "default" {}
# Create a default subnet in the specified availability zone
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_default_vpc.default.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}
# Create a key pair for Jenkins instance
resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "Jenkins-kp"
  public_key = tls_private_key.jenkins_key_pair.public_key_openssh
}
# Create an AWS EC2 instance with the specified AMI, instance type, and associated key pair
resource "aws_instance" "jenkins_instance" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  key_name             = aws_key_pair.jenkins_key_pair.key_name
  subnet_id            = aws_subnet.public_subnet.id
  user_data            = file("${path.module}/user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.jenkins_s3_access_profile.name
  tags = {
    Name = "Jenkins EC2"
  }
}
# Create a security group for the Jenkins instance
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security group for Jenkins instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_local_ip]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Generate a random suffix for the S3 bucket name
resource "random_string" "key_pair_suffix" {
  length  = var.random_suffix_length
  special = false
}
# Create an S3 bucket for Jenkins artifacts with the random suffix
resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket = "jenkins-artifacts-bucket-${lower(random_string.key_pair_suffix.result)}"
}
# Create an IAM role for Jenkins with S3 permissions
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Attach a policy to the IAM role granting S3 read and write access
resource "aws_iam_role_policy_attachment" "jenkins_s3_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.jenkins_role.name
}
# Create an IAM instance profile
resource "aws_iam_instance_profile" "jenkins_s3_access_profile" {
  name = "JenkinsS3AccessProfile"
  role = aws_iam_role.jenkins_role.name
}