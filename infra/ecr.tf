resource "aws_ecr_repository" "registry" {
  name                 = "my-app-registry"
  image_tag_mutability = "MUTABLE"
  force_delete = true 
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project_name
  }
}