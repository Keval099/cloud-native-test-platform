terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "ecr-lab"
}

resource "aws_s3_bucket" "terraform_lab" {
  bucket = var.bucket_name

  tags = {
    Name        = "cloud-native-test-platform-tf-lab"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}