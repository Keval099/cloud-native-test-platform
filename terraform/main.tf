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

module "s3_lab" {
  source = "./modules/s3-lab"

  bucket_name = var.bucket_name
}

moved {
  from = aws_s3_bucket.terraform_lab
  to   = module.s3_lab.aws_s3_bucket.terraform_lab
}