output "terraform_lab_bucket_name" {
  description = "Name of the Terraform learning S3 bucket"
  value       = aws_s3_bucket.terraform_lab.bucket
}