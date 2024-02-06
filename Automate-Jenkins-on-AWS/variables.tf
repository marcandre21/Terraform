# variables.tf
# Declaring variables
variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}
variable "instance_type" {
  description = "The type of EC2 instance for Jenkins"
  default     = "t2.micro"
}
variable "random_suffix_length" {
  description = "The length of the random suffix for keys and buckets"
  default     = 8
}
variable "default_vpc_cidr_block" {
  description = "CIDR block for the default VPC"
  default     = "172.31.0.0/16"
}
variable "public_subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  default     = "172.31.96.0/28"
}
variable "availability_zone" {
  description = "Availability zone for the resources"
  default     = "us-east-1d"
}
variable "my_local_ip" {
  description = "My public IP address for SSH access"
  type        = string
  default     = "172.31.64.0/20"
}