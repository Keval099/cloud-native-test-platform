resource "aws_s3_bucket" "terraform_lab" {
  bucket = var.bucket_name

  tags = {
    Name        = "cloud-native-test-platform-tf-lab"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}