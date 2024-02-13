# variables.tf
# AWS region where resources will be deployed
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}
# Key pair name for EC2 instances
variable "key_name" {
  description = "Key pair name"
  default     = "apache_key"
}
# AMI ID for the EC2 instances
variable "image_id" {
  description = "AMI ID for the EC2 instances"
  default     = "ami-0e731c8a588258d0d"
}
# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
# List of subnet IDs for the autoscaling group
variable "vpc_zone_identifiers" {
  description = "List of subnet IDs for the autoscaling group"
  type        = list(string)
  default     = ["subnet-08dbe7ecd07a77259", "subnet-0b2861a401cab90ba"]
}
# Name of the security group
variable "security_group_name" {
  description = "Name of the security group"
  default     = "apache-security-group"
}