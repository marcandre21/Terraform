# providers.tf
# Specify the AWS provider
provider "aws" {
  region     = var.aws_region
}
# Initialize the random provider
provider "random" {}