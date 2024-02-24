#variables.tf
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}
variable "pub_subnet1_cidr_block" {
  description = "CIDR block for the public subnet 1"
  type        = string
  default     = "10.1.1.0/24"
}
variable "pub_subnet2_cidr_block" {
  description = "CIDR block for the public subnet 2"
  type        = string
  default     = "10.1.2.0/24"
}
variable "pvt_subnet1_cidr_block" {
  description = "CIDR block for the private subnet 1"
  type        = string
  default     = "10.1.48.0/24"
}
variable "pvt_subnet2_cidr_block" {
  description = "CIDR block for the private subnet 2"
  type        = string
  default     = "10.1.64.0/24"
}