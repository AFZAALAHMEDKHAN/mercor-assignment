# ECS Blue/Green Deployment with Terraform & GitHub Actions

## Overview

This project demonstrates a production-style deployment pipeline on **AWS ECS Fargate** using **Terraform** as Infrastructure as Code (IaC) and **GitHub Actions** for CI/CD. The pipeline supports **Blue/Green deployments** with **AWS CodeDeploy** and ensures **zero-downtime upgrades** for both infrastructure and application layers.

The project consists of:

- Terraform-based infrastructure provisioning (`infra/` folder)  
- ECS Fargate application deployment (`app/` folder)  
- CI/CD pipeline via GitHub Actions (`.github/workflows/deploy.yml`)  
- Application Load Balancer (ALB) with access logs enabled  
- IAM roles and permissions for ECS, CodeDeploy, and task execution  
- S3 backend for Terraform state management  

---

## Workflow Flow & Zero-Downtime Handling (Proposed)

The GitHub Actions workflow triggers on **pushes to the `main` branch** affecting `app/` or `infra/` directories. It contains **two main jobs**: `infra_apply` and `app_deploy`.

---

### 1. Infrastructure Job (`infra_apply`)

**Purpose:** Apply infrastructure changes safely while maintaining zero downtime, including updates to Fargate task resources like CPU or memory.

**Key Steps:**

1. **Repository Checkout:** Pulls the latest code from GitHub.  
2. **Filtering Changes:** Uses `dorny/paths-filter@v2` to check if there are changes in the `infra/` folder.  
   - Skips Terraform apply if no infra changes are detected.  
3. **AWS Credentials Setup:** Configures AWS access for Terraform execution.  
4. **Terraform Setup:** Installs Terraform 1.6.0.  
5. **Terraform Execution:**  
   - `init` initializes the backend (S3) and providers.  
   - `fmt` and `validate` ensure Terraform code is correctly formatted and syntactically valid.  
   - `plan` previews changes.  
   - `apply` executes changes automatically if needed.  

**Zero-Downtime Mechanism (Infrastructure Changes / Phase 2):**

In **Fargate**, the underlying infrastructure (CPU, memory, OS, etc.) is defined entirely in the ECS **Task Definition**. Changing these parameters triggers ECS to register a **new Task Definition revision**. The pipeline ensures zero downtime as follows:

| Action | Mechanism / Result |
|--------|------------------|
| Modify infra variables (e.g., `fargate_cpu` 256 → 512) | GitHub Actions triggers `infra_apply`. |
| Terraform detects ECS task definition changes | Registers a new ECS Task Definition revision with the updated resources. |
| ECS Service update | Launches new tasks with updated resources while keeping old tasks running. |
| Traffic Shift | ALB routes traffic to new tasks only after health checks pass. Old tasks are drained after new tasks are healthy. |

This ensures **zero downtime** for infrastructure updates because:

- Old tasks continue to serve traffic until new tasks pass health checks.  
- `depends_on` ensures that ALB, listeners, and target groups exist before updating tasks.  
- All changes are applied via IaC and orchestrated automatically through GitHub Actions.  

---

### 2. Application Deployment Job (`app_deploy`)

**Purpose:** Build, push, and deploy the application using ECS and CodeDeploy with zero downtime.

**Key Steps:**

1. **Dependency:** Runs only after `infra_apply` completes successfully.  
2. **Repository Checkout:** Pulls the latest code.  
3. **AWS Credentials Setup:** Configures AWS access for deployment steps.  
4. **Terraform Setup for Outputs:**  
   - Retrieves ECS cluster, service, and ECR repository information from remote Terraform state.  
   - Exposes outputs as environment variables for subsequent steps.  
5. **Docker Build & Push:**  
   - Logs in to Amazon ECR.  
   - Builds the Docker image from the `app/` folder.  
   - Tags the image with the Git commit SHA.  
   - Pushes it to the ECR repository.  
6. **ECS Task Definition Registration:**  
   - Fetches the current ECS task definition.  
   - Updates the container image to the new version.  
   - Registers a new task definition revision via AWS CLI.  
7. **CodeDeploy Blue/Green Deployment:**  
   - Creates a deployment referencing the new ECS task definition.  
   - Configured with `deployment_ready_option` set to `CONTINUE_DEPLOYMENT` to ensure traffic shifts **only after new tasks pass ALB health checks**.  
   - Old (Blue) tasks are terminated only after Green tasks are healthy.  
   - Auto rollback is enabled to revert in case of deployment failure.  
8. **Deployment Monitoring:**  
   - Waits for deployment completion.  
   - Fails the job if CodeDeploy reports an error.  

---

### Zero-Downtime Handling Summary

- **Application Layer:** Blue/Green deployment ensures new tasks serve traffic only after health checks pass; old tasks remain active until then.  
- **Infrastructure Layer:** Terraform changes are applied sequentially using `depends_on` to prevent downtime. ECS service updates automatically create new task revisions for CPU/memory changes without terminating running tasks.  
- **Rollback:** Auto rollback is enabled in CodeDeploy to revert failed deployments.  

> **Note:** ECS task registration and CodeDeploy deployments are currently handled via AWS CLI commands in the workflow. Full GitHub Actions native integration faced JSON/AppSpec challenges, resolved via CLI steps.

---

## Production Considerations

- **ALB:** Access logs enabled and stored in S3 for monitoring.  
- **Security:** ECS tasks only accessible via ALB security group; IAM roles should follow least privilege in production.  
- **Observability:** CloudWatch logs and ECS container insights enabled.  
- **Improvements:** HTTPS for ALB, automated CI/CD tests, and fine-grained IAM policies recommended.  
