# Project Backlog

## Cloud Native Test Platform

Project status: **COMPLETED**

The project has reached its planned implementation scope.

The platform demonstrates an end-to-end cloud-native delivery workflow:

> Develop → Test → Containerize → Scan → Push → Provision → Deploy → Observe → Validate → Roll Back

---

# 1. Application

- [x] Build FastAPI application
- [x] Implement `/` endpoint
- [x] Implement `/health` endpoint
- [x] Support environment configuration through `APP_ENV`
- [x] Add automated application tests
- [x] Verify application locally

---

# 2. Docker

- [x] Create Dockerfile
- [x] Build application image locally
- [x] Run application inside Docker
- [x] Verify `/health` endpoint from container
- [x] Verify application root endpoint from container
- [x] Use lightweight Python base image

---

# 3. CI/CD

- [x] Create GitHub Actions workflow
- [x] Run Python tests in CI
- [x] Build Docker image in CI
- [x] Generate image tags from Git commit SHA
- [x] Scan Docker image with Trivy
- [x] Configure GitHub Actions OIDC authentication
- [x] Push container image to Amazon ECR
- [x] Authenticate GitHub Actions to EKS
- [x] Update EKS deployment image automatically
- [x] Wait for Kubernetes rollout
- [x] Run application smoke test
- [x] Verify application pods after deployment
- [x] Implement automatic deployment rollback
- [x] Test rollback using an intentionally failed deployment
- [x] Verify successful recovery after rollback

---

# 4. AWS Networking

- [x] Create/manage project VPC
- [x] Configure public subnets
- [x] Configure application/private subnets
- [x] Configure database subnets
- [x] Configure Internet Gateway
- [x] Configure route tables
- [x] Configure subnet route table associations
- [x] Configure NAT Gateway
- [x] Configure Elastic IP for NAT
- [x] Configure VPC DNS hostnames
- [x] Configure application security group
- [x] Configure ALB security group
- [x] Configure RDS security group
- [x] Apply least-privilege network access between tiers

---

# 5. Amazon ECR

- [x] Create ECR repository
- [x] Enable image scanning on push
- [x] Push application image to ECR
- [x] Use immutable-style commit SHA image identification in CI/CD
- [x] Verify ECR images
- [x] Integrate ECR with EKS deployment

---

# 6. Amazon EKS

- [x] Provision EKS cluster
- [x] Configure EKS cluster networking
- [x] Create managed node group
- [x] Configure worker node IAM role
- [x] Configure ECR image pull permissions
- [x] Configure EKS access
- [x] Configure GitHub Actions EKS access
- [x] Deploy application to EKS
- [x] Run multiple application replicas
- [x] Verify pods across EKS nodes
- [x] Configure Kubernetes readiness probe
- [x] Configure Kubernetes liveness probe
- [x] Configure Kubernetes Service
- [x] Verify rolling deployment
- [x] Verify application health on EKS

---

# 7. Kubernetes

- [x] Understand Kubernetes Deployment
- [x] Understand Kubernetes ReplicaSets
- [x] Understand Pods
- [x] Understand Services
- [x] Understand readiness probes
- [x] Understand liveness probes
- [x] Understand rolling updates
- [x] Understand rollout status
- [x] Understand rollback
- [x] Deploy application using Kubernetes manifests
- [x] Verify application using kubectl

> Kubernetes was intentionally kept at a foundational operational level.
> The project does not aim to demonstrate advanced Kubernetes specialization.

---

# 8. Infrastructure as Code

- [x] Install and configure Terraform
- [x] Configure AWS provider
- [x] Configure Terraform state
- [x] Practice Terraform initialization
- [x] Practice Terraform plan
- [x] Practice Terraform apply
- [x] Practice Terraform validation and formatting
- [x] Practice configuration drift detection
- [x] Practice resource import
- [x] Import existing VPC resources
- [x] Import existing subnet resources
- [x] Import route tables and associations
- [x] Import security groups
- [x] Manage NAT Gateway with Terraform
- [x] Manage ECR with Terraform
- [x] Manage EKS with Terraform
- [x] Manage IAM with Terraform
- [x] Manage EKS access entries with Terraform
- [x] Manage EKS Pod Identity with Terraform
- [x] Manage CloudWatch observability add-ons with Terraform
- [x] Verify Terraform plan has no unexpected changes

---

# 9. IAM and Security

- [x] Create dedicated EKS cluster IAM role
- [x] Create dedicated EKS node IAM role
- [x] Configure required AWS managed policies
- [x] Create GitHub Actions ECR role
- [x] Create GitHub Actions EKS role
- [x] Configure GitHub Actions OIDC trust
- [x] Avoid long-lived AWS credentials in GitHub Actions
- [x] Configure EKS access entry for GitHub Actions
- [x] Scope GitHub Actions Kubernetes access to the application namespace
- [x] Configure EKS Pod Identity for CloudWatch
- [x] Apply security-group-based network access controls

---

# 10. Observability

- [x] Install Amazon CloudWatch Observability EKS add-on
- [x] Configure EKS Pod Identity Agent
- [x] Configure CloudWatch IAM role
- [x] Configure CloudWatch Pod Identity association
- [x] Collect application logs
- [x] Collect Kubernetes/container logs
- [x] Verify CloudWatch log streams
- [x] Verify application `/health` logs
- [x] Collect Container Insights metrics
- [x] Monitor node CPU utilization
- [x] Monitor pod CPU utilization
- [x] Monitor pod memory utilization
- [x] Monitor failed nodes
- [x] Create CloudWatch dashboard
- [x] Create CloudWatch alarms
- [x] Verify alarm state

---

# 11. Validation and Recovery

- [x] Validate local application
- [x] Validate Docker container
- [x] Validate ECR image
- [x] Validate EKS deployment
- [x] Validate Kubernetes pods
- [x] Validate application health endpoint
- [x] Validate application root endpoint
- [x] Validate GitHub Actions pipeline
- [x] Validate deployment rollout
- [x] Validate smoke test
- [x] Intentionally introduce failed deployment
- [x] Detect failed rollout
- [x] Automatically roll back deployment
- [x] Validate application recovery

---

# 12. Documentation

- [x] Document architecture
- [x] Document infrastructure
- [x] Document CI/CD workflow
- [x] Document Kubernetes deployment
- [x] Document Terraform implementation
- [x] Document IAM/OIDC configuration
- [x] Document observability
- [x] Capture implementation evidence
- [x] Capture CI/CD evidence
- [x] Capture rollback evidence
- [x] Capture AWS infrastructure evidence

---

# Final Status

## Project complete

The planned implementation scope has been completed.

The project demonstrates:

- Application development
- Automated testing
- Docker containerization
- Container security scanning
- Amazon ECR
- Amazon EKS
- Kubernetes fundamentals
- Terraform infrastructure as code
- AWS IAM
- GitHub Actions
- GitHub OIDC
- Automated deployment
- Automated rollback
- CloudWatch observability
- CloudWatch metrics and alarms
- Application logging
- Operational validation

Advanced Kubernetes specialization, Prometheus/Grafana, ALB/Ingress-based external application exposure, and additional production platform features are outside the final scope of this project.