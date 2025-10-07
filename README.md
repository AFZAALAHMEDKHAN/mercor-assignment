# ECS Blue/Green Deployment with Terraform & GitHub Actions

## Overview

This project demonstrates a production-style deployment pipeline on AWS ECS using Terraform as Infrastructure as Code (IaC) and GitHub Actions for CI/CD. It supports Blue/Green deployments with AWS CodeDeploy and ensures zero-downtime upgrades for both infrastructure and application layers.

The project consists of:

- Terraform-based infrastructure provisioning (`infra/` folder)
- ECS Fargate application deployment (`app/` folder)
- CI/CD pipeline via GitHub Actions (`.github/workflows/deploy.yml`)
- Application Load Balancer (ALB) with access logs
- IAM roles and permissions for ECS, CodeDeploy, and task execution
- S3 backend for Terraform state management

## Workflow Flow & Zero-Downtime Handling

The GitHub Actions workflow triggers on pushes to the `main` branch affecting `app/` or `infra/` directories.

### 1. Infrastructure Job (`infra_apply`)

- Checks for changes in `infra/` folder
- Runs Terraform `init`, `validate`, `plan`, and `apply`
- Uses `depends_on` and Terraform modules to ensure proper provisioning order
- Updates infrastructure with zero downtime by carefully sequencing ECS, ALB, target groups, and VPC updates

### 2. Application Deployment Job (`app_deploy`)

- Retrieves outputs from Terraform remote state (ECS cluster, service, ECR repo, etc.)
- Builds, tags, and pushes Docker image to ECR
- Registers a new ECS task definition via AWS CLI
- Creates a CodeDeploy Blue/Green deployment
- Waits for successful deployment; rollback occurs automatically on failure

### Zero-Downtime Implementation

- **Application**: Blue/Green deployment ensures old tasks remain serving until new tasks are healthy. Traffic only shifts to the new task set after passing ALB health checks.
- **Infrastructure**: Terraform changes (e.g., ECS service, ALB, VPC) are applied in sequence using `depends_on` to avoid resource downtime.
- **Rollback**: Auto rollback enabled in CodeDeploy ensures failed deployments do not affect live traffic.

> **Note:** ECS task registration and CodeDeploy deployments are currently handled via CLI commands in the workflow. Full GitHub Actions native integration faced JSON/AppSpec challenges, which were resolved using CLI steps.

## Production Considerations

- ALB access logs enabled for traffic monitoring
- ECS tasks only accessible via ALB security group
- CloudWatch logs and ECS container insights enabled for observability
- IAM roles currently use demo/admin-level permissions; production should follow least privilege principle
- HTTPS and CI/CD testing can be added for enhanced production readiness
