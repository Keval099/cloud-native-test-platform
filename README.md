# Cloud-Native Test Automation & Deployment Platform

A production-style cloud-native application and DevOps learning project built to demonstrate modern application development, containerization, CI/CD, AWS security, container image management, and foundational Kubernetes operations.

The project is being developed incrementally, with each stage implemented, tested, documented, and integrated into the overall platform.

---

## Current Technology Stack

### Application

* Python
* FastAPI
* Uvicorn
* Pytest
* HTTPX

### Containerization

* Docker
* Dockerfile
* Docker Desktop

### CI/CD

* GitHub Actions
* GitHub Actions OIDC
* AWS IAM
* Amazon ECR
* Trivy

### AWS

* Amazon ECR
* AWS IAM
* AWS STS
* AWS VPC
* Internet Gateway
* Security Groups
* Application Load Balancer concepts
* Amazon RDS concepts

### Kubernetes

* Kubernetes fundamentals
* Pods
* Deployments
* ReplicaSets
* Services
* Ingress fundamentals
* ConfigMaps
* Secrets
* Health probes
* Rolling updates
* Rollbacks
* Blue-Green deployments
* Kubernetes troubleshooting

### Planned Infrastructure & Observability

* Amazon EKS
* Terraform
* Amazon RDS
* AWS Secrets Manager
* CloudWatch
* Prometheus
* Grafana

---

# Project Architecture

The project is being built in stages.

### Current application and CI/CD flow

```text
Developer
    |
    | Git push / Pull Request
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    +--> Install dependencies
    |
    +--> Run Pytest
    |
    +--> Build Docker image
    |
    +--> Trivy image security scan
    |
    +--> GitHub OIDC
    |
    +--> AWS IAM Role
    |
    +--> Authenticate to Amazon ECR
    |
    +--> Tag Docker image
    |
    +--> Push image to Amazon ECR
    |
    v
Amazon ECR
```

---

# Application

The current application is a lightweight FastAPI service used as the foundation for the cloud-native platform.

## Endpoints

### Root

```text
GET /
```

Returns application information and the current environment.

### Health

```text
GET /health
```

Returns the application health status.

Example:

```json
{
  "status": "healthy"
}
```

The application currently uses an environment variable for the application environment:

```text
APP_ENV
```

If no value is provided, the application defaults to:

```text
development
```

---

# Automated Tests

The application currently has automated API tests using Pytest and FastAPI's test client.

Current tests verify:

* Root endpoint availability
* Root endpoint response
* Health endpoint availability
* Health endpoint response

Run tests locally with:

```bash
pytest
```

Current test suite:

```text
2 tests
2 passed
```

---

# Docker

The FastAPI application is containerized using Docker.

Current Docker image:

```text
cloud-native-test-platform:ci
```

The container exposes:

```text
8000
```

Example local build:

```bash
docker build -f docker/labs/Dockerfile -t cloud-native-test-platform:ci .
```

Run locally:

```bash
docker run -d \
  --name cloud-native-test-platform-ci \
  -p 8000:8000 \
  cloud-native-test-platform:ci
```

Test:

```bash
curl http://localhost:8000/health
```

---

# CI/CD Pipeline

GitHub Actions automates the current CI/CD process.

The pipeline currently performs:

```text
Checkout
   |
   v
Set up Python
   |
   v
Install dependencies
   |
   v
Run Pytest
   |
   v
Build Docker image
   |
   v
Trivy security scan
   |
   v
Authenticate to AWS using GitHub OIDC
   |
   v
Assume AWS IAM Role
   |
   v
Authenticate Docker to ECR
   |
   v
Tag Docker image
   |
   v
Push image to ECR
```

## GitHub Actions

The workflow is located at:

```text
.github/workflows/ci.yaml
```

The workflow runs automated tests and builds the Docker image.

---

# Container Security Scanning

Trivy is used to scan the Docker image for known vulnerabilities.

Example scan findings are surfaced directly in the GitHub Actions workflow.

The current pipeline reports vulnerabilities but does not yet fail the build based on severity.

A future improvement will be to define a vulnerability threshold, for example:

```text
HIGH / CRITICAL
```

and fail the pipeline when the threshold is exceeded.

---

# AWS Authentication

GitHub Actions does not use long-lived AWS access keys for this project.

Instead, the pipeline uses:

```text
GitHub Actions
      |
      v
GitHub OIDC
      |
      v
AWS STS
      |
      v
IAM Role
      |
      v
Temporary AWS credentials
```

The IAM role is:

```text
GitHubActions-ECR-CloudNativeTestPlatform
```

The role trust policy restricts access to the project's GitHub repository and `main` branch.

This demonstrates an important DevSecOps principle:

> Avoid storing long-lived cloud credentials in CI/CD systems when short-lived federated credentials can be used.

---

# Amazon ECR

The Docker image is stored in the following ECR repository:

```text
cloud-native-test-platform
```

AWS Region:

```text
ap-south-1
```

Current image:

```text
cloud-native-test-platform:ci
```

The GitHub Actions pipeline automatically pushes the image to ECR after successful testing, Docker build, and security scanning.

---

# IAM Least Privilege

The GitHub Actions IAM role does not have administrator access.

The role is restricted to the ECR operations required by the pipeline.

The architecture separates:

### Trust

Who can assume the role?

```text
GitHub Actions
    |
    v
OIDC
    |
    v
Specific repository + main branch
```

### Permissions

What can the role do?

```text
ECR operations
    |
    v
cloud-native-test-platform repository
```

This separation demonstrates AWS IAM trust relationships and least-privilege authorization.

---

# AWS Network Architecture

A foundational AWS VPC design has been created with separate subnet tiers.

```text
                    Internet
                       |
                       v
                Internet Gateway
                       |
          +------------+------------+
          |                         |
      Public Subnet             Public Subnet
          |                         |
          +------------+------------+
                       |
                 Application
                  Tier / EKS
                  Private Subnets
                       |
                       v
                   RDS / DB
                  Private Subnets
```

The intended architecture separates:

* Public-facing resources
* Application resources
* Database resources

Security groups are designed to restrict communication between tiers.

---

# Kubernetes Learning

The project includes foundational Kubernetes labs.

The goal is to understand how Kubernetes is used to run and operate containerized applications rather than becoming a Kubernetes specialization project.

Topics completed include:

* Pods
* Deployments
* ReplicaSets
* Services
* ClusterIP
* NodePort
* Ingress fundamentals
* ConfigMaps
* Secrets
* Liveness probes
* Readiness probes
* Pod troubleshooting
* Logs
* Events
* `kubectl describe`
* Rolling updates
* Rollbacks
* Blue-Green deployments

---

# Kubernetes Troubleshooting

The project includes deliberate failure scenarios to practice troubleshooting.

Basic troubleshooting workflow:

```text
kubectl get pods
        |
        v
kubectl logs <pod>
        |
        v
kubectl describe pod <pod>
        |
        v
kubectl get events
```

Failure scenarios practiced include:

* CrashLoopBackOff
* Application failures
* Deployment failures
* Service configuration problems
* Rollback scenarios
* Blue-Green traffic switching

---

# Blue-Green Deployment

A foundational Blue-Green deployment has been implemented in Kubernetes.

The concept:

```text
             Service
                |
        +-------+-------+
        |               |
      BLUE            GREEN
       v1               v2
```

Both versions can run simultaneously.

The Kubernetes Service selector determines which version receives traffic.

Example:

```text
Service
   |
   +--> BLUE  = active
   |
   +--> GREEN = inactive
```

After switching the selector:

```text
Service
   |
   +--> GREEN = active
   |
   +--> BLUE  = inactive
```

Rollback can be performed by switching the Service selector back.

---

# Project Structure

```text
cloud-native-test-platform/
│
├── .github/
│   └── workflows/
│       └── ci.yaml
│
├── app/
│   ├── __init__.py
│   ├── main.py
│   └── requirements.txt
│
├── docker/
│   └── labs/
│       └── Dockerfile
│
├── Kubernetes/
│   └── labs/
│
├── tests/
│   └── test_app.py
│
├── Notes/
│
├── Docs/
│
├── linus-lab/
│
├── .gitignore
├── pytest.ini
└── README.md
```

---

# Current Status

## Completed

* [x] FastAPI application
* [x] Root API endpoint
* [x] Health endpoint
* [x] Automated Pytest tests
* [x] Docker containerization
* [x] Local Docker validation
* [x] GitHub Actions CI
* [x] Automated Python tests in CI
* [x] Docker image build in CI
* [x] Trivy image security scanning
* [x] AWS OIDC provider
* [x] GitHub Actions OIDC authentication
* [x] IAM role for GitHub Actions
* [x] IAM least-privilege ECR permissions
* [x] ECR authentication from GitHub Actions
* [x] Automated Docker image push to ECR
* [x] AWS VPC foundational design
* [x] Kubernetes fundamentals
* [x] Kubernetes troubleshooting labs
* [x] Rolling updates
* [x] Rollbacks
* [x] Blue-Green deployment fundamentals

---

# In Progress / Planned

* [ ] Version Docker images using Git commit SHA
* [ ] Improve Trivy CI failure policy
* [ ] Create Kubernetes deployment manifests for the application
* [ ] Deploy application to Amazon EKS
* [ ] Configure AWS ALB / Kubernetes ingress integration
* [ ] Configure RDS
* [ ] Integrate application with PostgreSQL
* [ ] Implement Terraform
* [ ] Terraform VPC
* [ ] Terraform ECR
* [ ] Terraform IAM
* [ ] Terraform EKS
* [ ] Terraform RDS
* [ ] Configure AWS Secrets Manager
* [ ] CloudWatch logging and metrics
* [ ] Prometheus
* [ ] Grafana
* [ ] Application metrics
* [ ] Alerts
* [ ] Additional failure-recovery scenarios

---

# Learning Objectives

This project is designed to demonstrate practical understanding of:

* Linux fundamentals
* Git and GitHub workflows
* Python API development
* Automated API testing
* Docker
* Container security
* GitHub Actions
* CI/CD
* AWS IAM
* OIDC federation
* AWS STS
* Amazon ECR
* AWS networking
* Kubernetes fundamentals
* Deployment strategies
* Troubleshooting
* Infrastructure as Code
* Cloud observability
* DevSecOps practices

The project intentionally progresses from local development to containerization, CI/CD, AWS container management, Kubernetes, infrastructure automation, and observability.

---

# Long-Term Target Architecture

The intended final architecture will evolve toward:

```text
Developer
    |
    v
GitHub
    |
    v
GitHub Actions
    |
    +--> Tests
    |
    +--> Docker Build
    |
    +--> Security Scan
    |
    +--> OIDC / IAM
    |
    v
Amazon ECR
    |
    v
Amazon EKS
    |
    v
AWS Load Balancer
    |
    v
FastAPI Application
    |
    v
Amazon RDS
```

Supporting services will include:

```text
Terraform
AWS IAM
AWS Secrets Manager
CloudWatch
Prometheus
Grafana
```

The final architecture will be implemented incrementally rather than all at once.
