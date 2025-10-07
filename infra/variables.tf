variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecs-bluegreen"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "List of AZs for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}


variable "fargate_cpu" {
  description = "Fargate Task CPU units (e.g., 256, 512, 1024)"
  type        = number
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate Task Memory (e.g., 512, 1024, 2048)"
  type        = number
  default     = "512"
}
