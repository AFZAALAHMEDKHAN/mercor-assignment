module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2" # or latest stable

  name = "ecs-vpc"
  cidr = var.vpc_cidr

  azs                = var.availability_zones
  public_subnets     = var.public_subnets
  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true # by default true

  tags = {
    Project = var.project_name
    Owner   = "Afzaal"
  }
}
