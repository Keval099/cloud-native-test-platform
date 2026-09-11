output "terraform_lab_bucket_name" {
  description = "Name of the Terraform learning S3 bucket"
  value       = module.s3_lab.bucket_name
}