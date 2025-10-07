terraform {
  backend "s3" {
    bucket  = "mercor-ecs-bluegreen-tfstate"
    key     = "environments/ecs-bluegreen/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}