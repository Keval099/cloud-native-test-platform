resource "aws_ecr_repository" "app" {
  name                 = "cloud-native-test-platform"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "cloud-native-test-platform"
    ManagedBy = "Terraform"
  }
}