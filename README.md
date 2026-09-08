# Cloud-Native Test Automation & Deployment Platform

A hands-on cloud and DevOps learning project demonstrating application development, containerization, CI/CD, AWS security, container image management, foundational Kubernetes, Amazon EKS, and automated deployment.

The project is intentionally built incrementally so each technology is implemented, tested, troubleshot, and documented before moving to the next stage.

---

## Current Technology Stack

### Application
- Python
- FastAPI
- Uvicorn
- Pytest
- HTTPX

### Containerization
- Docker
- Dockerfile
- Docker Desktop

### CI/CD & Security
- GitHub Actions
- GitHub Actions OIDC
- AWS IAM / STS
- Amazon ECR
- Trivy
- Git commit SHA image tagging

### AWS
- Amazon VPC
- Internet Gateway
- NAT Gateway
- Security Groups
- Amazon ECR
- Amazon EKS
- EKS Managed Node Group
- EKS Access Entries
- IAM least privilege
- Application Load Balancer / Ingress concepts
- Amazon RDS concepts

### Kubernetes
- Pods
- Deployments
- ReplicaSets
- Services / ClusterIP
- ConfigMaps
- Secrets
- Liveness and readiness probes
- Rolling updates
- Rollbacks
- Blue-Green deployment fundamentals
- Kubernetes troubleshooting
- Amazon EKS

### Planned
- AWS Load Balancer / Ingress integration
- Amazon RDS PostgreSQL
- AWS Secrets Manager
- Terraform
- CloudWatch
- Prometheus
- Grafana
- Application metrics and alerting

---

# Current Architecture

The current project has a working end-to-end CI/CD path from a merged GitHub change to a running application on Amazon EKS.

```text
Developer
    |
    | Pull Request
    v
GitHub
    |
    v
GitHub Actions
    |
    +--> Tests
    +--> Docker Build
    +--> Trivy Scan
    |
    | PR only
    |------------------------------> STOP
    |
    | Merge to main
    v
GitHub SHA
    |
    +--> Docker image :<SHA>
    |
    +--> OIDC
            |
            +--> ECR IAM Role
            |       |
            |       v
            |      ECR
            |
            +--> EKS IAM Role
                    |
                    v
                 EKS API
                    |
                    v
             kubectl set image
                    |
                    v
             EKS Deployment
                    |
              +-----+-----+
              |           |
            Pod A       Pod B
              |           |
              +-----+-----+
                    |
                 Service
                    |
                 FastAPI
```

### SHA traceability

The same short Git commit SHA is used to identify the build artifact and deployment:

```text
Git commit
    |
    +--> Docker image :47193a1
    |
    +--> ECR :47193a1
    |
    +--> EKS Deployment :47193a1
```

This avoids relying on a moving `latest` tag and provides traceability from a running workload back to the source commit.

---

# Application

The current application is a lightweight FastAPI service.

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

Returns:

```json
{
  "status": "healthy"
}
```

The application uses:

```text
APP_ENV
```

and defaults to:

```text
development
```

---

# Automated Tests

The project uses Pytest with FastAPI's test client.

Current tests cover:
- Root endpoint availability and response
- Health endpoint availability and response

Run locally:

```bash
pytest
```

---

# Docker

The application is containerized with the Dockerfile at:

```text
docker/labs/Dockerfile
```

Build locally:

```bash
docker build -f docker/labs/Dockerfile -t cloud-native-test-platform:ci .
```

Run:

```bash
docker run -d   --name cloud-native-test-platform-ci   -p 8000:8000   cloud-native-test-platform:ci
```

Test:

```bash
curl http://localhost:8000/health
```

---

# CI/CD Pipeline

The workflow is:

```text
Pull Request
    |
    +--> Checkout
    +--> Python setup
    +--> Install dependencies
    +--> Pytest
    +--> Docker build
    +--> Trivy scan
    |
    +--> AWS/ECR steps skipped
    +--> EKS deployment skipped


Merge to main
    |
    +--> Checkout
    +--> Python setup
    +--> Install dependencies
    +--> Pytest
    +--> Docker build
    +--> Trivy scan
    |
    +--> GitHub OIDC
    +--> ECR IAM role
    +--> ECR login
    +--> Push :<SHA>
    |
    +--> EKS IAM role
    +--> Update kubeconfig
    +--> Deploy :<SHA>
    +--> Rollout verification
    +--> Pod verification
```

Workflow:

```text
.github/workflows/ci.yaml
```

### Image versioning

The workflow creates the image tag from the GitHub commit:

```text
IMAGE_TAG=${GITHUB_SHA::7}
```

The same tag is used for:
- Docker image
- ECR image
- EKS deployment

### Deployment

The CD stage updates the existing Kubernetes Deployment with:

```text
kubectl set image
```

and then waits for:

```text
kubectl rollout status
```

This allows `deployment.yaml` to remain a reusable base manifest rather than being manually changed for every Git commit.

---

# GitHub OIDC and IAM

GitHub Actions uses short-lived AWS credentials through OIDC rather than storing long-lived AWS access keys.

```text
GitHub Actions
      |
      v
GitHub OIDC token
      |
      v
AWS STS
      |
      v
IAM Role
      |
      v
Temporary credentials
```

Two separate roles are used:

```text
GitHubActions-ECR-CloudNativeTestPlatform
    |
    +--> ECR operations


GitHubActions-EKS-CloudNativeTestPlatform
    |
    +--> EKS deployment access
```

The EKS deployment role is connected to the cluster through an EKS Access Entry and is scoped to the `default` namespace with an edit-level EKS access policy.

This separation demonstrates:
- OIDC federation
- IAM trust policies
- least privilege
- separation of artifact publishing and deployment permissions

---

# Amazon ECR

Repository:

```text
cloud-native-test-platform
```

Region:

```text
ap-south-1
```

Images are published using Git commit SHA tags, for example:

```text
cloud-native-test-platform:47193a1
```

The older `ci` tag may still exist as a development artifact, but the deployment pipeline uses SHA-based tags for traceability.

---

# AWS Network Architecture

The VPC uses separate public, application, and database subnet tiers across two Availability Zones.

```text
VPC 10.0.0.0/16

ap-south-1a                    ap-south-1b
    |                              |
Public A                       Public B
    |                              |
    +--------- Internet Gateway ---+
                 |
              NAT Gateway
                 |
        +--------+--------+
        |                 |
     App A              App B
        |                 |
      EKS Node          EKS Node
        |                 |
        +--------+--------+
                 |
             DB tier
        DB A / DB B
```

The application/EKS subnets use the NAT Gateway for outbound internet connectivity.

The database subnets remain private and do not have a direct internet route.

> The current public EKS API endpoint is temporarily open to `0.0.0.0/0` for this short-lived learning environment so GitHub-hosted runners can reach the Kubernetes API. This is a lab-only choice and should be restricted or removed before treating the architecture as production.

---

# Amazon EKS

The project now runs the FastAPI application on Amazon EKS using a managed EC2 node group.

Current workload model:

```text
EKS Cluster
    |
    +-- Node A
    |     |
    |    Pod
    |
    +-- Node B
          |
         Pod
```

The application Deployment runs two replicas with:
- Readiness probe
- Liveness probe
- `APP_ENV=kubernetes`
- Kubernetes Service on port `8000`

The Service is currently:

```text
Type: ClusterIP
Port: 8000
```

The initial deployment was bootstrapped manually; subsequent image updates are automated through GitHub Actions.

---

# Kubernetes Learning

The project intentionally focuses on foundational Kubernetes knowledge rather than deep Kubernetes specialization.

Completed topics include:
- Pods
- Nodes
- Deployments
- ReplicaSets
- Services
- ClusterIP
- ConfigMaps
- Secrets
- Health probes
- Logs
- Events
- `kubectl describe`
- Rolling updates
- Rollbacks
- Blue-Green deployments
- Basic networking and service discovery
- EKS deployment

---

# Kubernetes Troubleshooting

Basic workflow:

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
- CrashLoopBackOff
- Application failures
- Deployment failures
- Service configuration problems
- Rollbacks
- Blue-Green traffic switching
- EKS node-join troubleshooting

---

# Blue-Green Deployment

A foundational Blue-Green deployment was implemented locally.

```text
             Service
                |
        +-------+-------+
        |               |
      BLUE            GREEN
       v1               v2
```

Both versions can run simultaneously.

The Service selector determines which version receives traffic.

Rollback is performed by switching the selector back to the previous version.

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
│       ├── deployment.yaml
│       └── service.yaml
│
├── tests/
│   └── test_app.py
│
├── Notes/
├── Docs/
├── linus-lab/
├── .gitignore
├── pytest.ini
└── README.md
```

---

# Current Status

## Completed

- [x] FastAPI application
- [x] Root and health endpoints
- [x] Automated Pytest tests
- [x] Docker containerization
- [x] Local Docker validation
- [x] GitHub Actions CI
- [x] PR validation workflow
- [x] Docker image build in CI
- [x] Trivy image scanning
- [x] GitHub OIDC
- [x] ECR IAM role
- [x] EKS deployment IAM role
- [x] EKS Access Entry
- [x] Least-privilege ECR permissions
- [x] SHA-based image versioning
- [x] Automated image push to ECR
- [x] Automated deployment to EKS
- [x] Automated rollout verification
- [x] EKS application deployment
- [x] Kubernetes Service
- [x] AWS VPC foundational architecture
- [x] NAT Gateway
- [x] Kubernetes fundamentals
- [x] Kubernetes troubleshooting labs
- [x] Rolling updates
- [x] Rollbacks
- [x] Blue-Green deployment fundamentals

## Next

- [ ] Improve Trivy CI failure policy
- [ ] Configure AWS ALB / Kubernetes ingress integration
- [ ] Create RDS PostgreSQL
- [ ] Integrate application with PostgreSQL
- [ ] Configure AWS Secrets Manager
- [ ] Implement Terraform
- [ ] Terraform VPC
- [ ] Terraform IAM
- [ ] Terraform ECR
- [ ] Terraform EKS
- [ ] Terraform RDS
- [ ] CloudWatch logging and metrics
- [ ] Prometheus
- [ ] Grafana
- [ ] Application metrics
- [ ] Alerts
- [ ] Deployment smoke tests
- [ ] Automated rollback strategy
- [ ] Additional failure-recovery scenarios
- [ ] Cost and teardown documentation

---

# Learning Objectives

This project is designed to demonstrate practical understanding of:

- Linux fundamentals
- Git and GitHub workflows
- Python API development
- Automated API testing
- Docker
- Container security
- GitHub Actions
- CI/CD
- AWS IAM
- OIDC federation
- AWS STS
- Amazon ECR
- Amazon EKS
- AWS networking
- Kubernetes fundamentals
- Deployment strategies
- Troubleshooting
- Infrastructure as Code
- Cloud observability
- DevSecOps practices

The project intentionally progresses from local development to containerization, CI/CD, AWS, Kubernetes/EKS, infrastructure automation, and observability.

---

# Long-Term Target Architecture

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
    +--> Docker Build
    +--> Trivy
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
FastAPI
    |
    v
Amazon RDS
```

Supporting services:

```text
Terraform
AWS Secrets Manager
CloudWatch
Prometheus
Grafana
```

The architecture will continue to evolve incrementally rather than introducing all components at once.
