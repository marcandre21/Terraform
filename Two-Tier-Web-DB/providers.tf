#providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4"
    }
  }

  cloud {
    organization = "marcandrepl"

    workspaces {
      name = "Two-Tier-Web-DB"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}