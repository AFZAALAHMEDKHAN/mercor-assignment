output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "List of public subnets"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.registry.repository_url
  description = "URL of the ECR repository for ECS images"
}

output "alb_dns" {
  value       = aws_lb.app.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "blue_target_group_arn" {
  value       = aws_lb_target_group.blue.arn
  description = "ARN of the blue target group"
}

output "green_target_group_arn" {
  value       = aws_lb_target_group.green.arn
  description = "ARN of the green target group"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "ARN of the ECS task execution role"
}

output "ecs_service_role_arn" {
  value       = aws_iam_role.ecs_service_role.arn
  description = "ARN of the ECS service role"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.app_cluster.name
  description = "Name of the ECS cluster"
}

output "ecs_service_name" {
  value       = aws_ecs_service.app_service.name
  description = "Name of the ECS service"
}


output "ecs_task_sg_id" {
  value       = aws_security_group.ecs_task_sg.id
  description = "ID of the ECS task security group"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ID of the ALB security group"
}
