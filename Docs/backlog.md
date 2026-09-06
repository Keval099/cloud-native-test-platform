# Project Backlog

## Application

- [x] Create FastAPI application
- [x] Create application health endpoint
- [x] Implement basic application environment configuration
- [ ] Create PostgreSQL database
- [ ] Implement Employee API
- [ ] Implement Leave API
- [ ] Add request validation
- [x] Add automated API tests
- [ ] Add integration tests
- [ ] Add application-level error handling

---

## Containerization

- [x] Create Dockerfile
- [x] Build Docker image
- [x] Run application locally in Docker
- [x] Validate container health endpoint
- [ ] Move production Dockerfile to final project location
- [ ] Create Docker Compose setup
- [ ] Add container health checks
- [ ] Improve Docker image security
- [x] Troubleshoot container failures
- [ ] Document container troubleshooting

---

## CI/CD

- [x] Create GitHub Actions CI
- [x] Checkout repository in GitHub Actions
- [x] Set up Python in CI
- [x] Install Python dependencies in CI
- [x] Run Python tests in CI
- [x] Build Docker image in CI
- [x] Scan Docker image with Trivy
- [x] Configure GitHub OIDC
- [x] Create AWS IAM role for GitHub Actions
- [x] Configure IAM trust policy for GitHub repository
- [x] Configure least-privilege ECR permissions
- [x] Authenticate GitHub Actions with AWS using OIDC
- [x] Authenticate Docker with Amazon ECR
- [x] Tag Docker image for ECR
- [x] Push Docker image to ECR
- [ ] Use Git commit SHA for Docker image tags
- [ ] Add immutable/versioned image tagging strategy
- [ ] Configure Trivy to fail CI on HIGH/CRITICAL vulnerabilities
- [ ] Deploy application to EKS
- [ ] Run deployment smoke tests
- [ ] Add deployment rollback strategy

---

## AWS

### IAM

- [x] Create GitHub OIDC identity provider
- [x] Create GitHub Actions IAM role
- [x] Configure IAM trust relationship
- [x] Restrict trust to repository and main branch
- [x] Configure least-privilege ECR permissions
- [ ] Review IAM policies for further least-privilege improvements

### ECR

- [x] Create ECR repository
- [x] Build Docker image locally
- [x] Push Docker image manually to ECR
- [x] Push Docker image automatically from GitHub Actions
- [ ] Enable ECR scan-on-push
- [ ] Define image retention/lifecycle policy
- [ ] Implement immutable image versioning

### Networking

- [x] Design AWS VPC
- [x] Create public subnets
- [x] Create private application subnets
- [x] Create private database subnets
- [x] Configure Internet Gateway
- [x] Configure route tables
- [x] Configure subnet associations
- [x] Design security group communication between tiers
- [ ] Configure NAT Gateway if required
- [ ] Perform network security review

### Compute / Platform

- [ ] Create EKS cluster
- [ ] Configure EKS worker nodes / compute
- [ ] Deploy application to EKS
- [ ] Configure Kubernetes networking
- [ ] Configure ALB integration

### Database

- [ ] Create RDS PostgreSQL
- [ ] Configure RDS security group
- [ ] Connect application to PostgreSQL
- [ ] Configure database credentials securely
- [ ] Test application-to-database connectivity

### Secrets

- [ ] Create AWS Secrets Manager secret
- [ ] Integrate application with Secrets Manager
- [ ] Remove database secrets from configuration
- [ ] Configure Kubernetes secret integration

### Observability

- [ ] Configure CloudWatch logs
- [ ] Configure CloudWatch metrics
- [ ] Configure application logging
- [ ] Configure application metrics

---

## Infrastructure as Code

- [ ] Learn Terraform basics
- [ ] Create Terraform project structure
- [ ] Terraform VPC
- [ ] Terraform networking
- [ ] Terraform ECR
- [ ] Terraform IAM
- [ ] Terraform EKS
- [ ] Terraform RDS
- [ ] Terraform security groups
- [ ] Terraform variables
- [ ] Terraform outputs
- [ ] Terraform remote state
- [ ] Document Terraform workflow

---

## Kubernetes Fundamentals

- [x] Learn Pods
- [x] Learn Deployments
- [x] Learn ReplicaSets
- [x] Learn Services
- [x] Learn ClusterIP
- [x] Learn NodePort
- [x] Learn Ingress fundamentals
- [x] Learn ConfigMaps
- [x] Learn Secrets
- [x] Add health probes
- [ ] Configure resource limits
- [ ] Configure HPA
- [x] Practice Kubernetes troubleshooting
- [x] Troubleshoot CrashLoopBackOff
- [x] Inspect Kubernetes logs
- [x] Inspect Kubernetes events
- [x] Use kubectl describe
- [x] Practice rolling updates
- [x] Practice deployment rollback
- [x] Practice Blue-Green deployment
- [ ] Deploy the actual application to Kubernetes
- [ ] Deploy the application to EKS

---

## Deployment Strategies

- [x] Understand rolling deployment
- [x] Practice rolling update
- [x] Practice rollback
- [x] Understand Blue-Green deployment
- [x] Implement foundational Blue-Green deployment
- [ ] Integrate Blue-Green deployment with CI/CD
- [ ] Implement automated deployment validation
- [ ] Implement automated rollback

---

## Observability

- [ ] CloudWatch logs
- [ ] CloudWatch metrics
- [ ] Application logging
- [ ] Application metrics
- [ ] Prometheus
- [ ] Grafana
- [ ] Create dashboards
- [ ] Configure alerts
- [ ] Monitor application health
- [ ] Monitor infrastructure health

---

## Security

- [x] IAM least privilege
- [x] GitHub OIDC authentication
- [x] Container image scanning
- [ ] Dependency vulnerability scanning
- [ ] Secrets management
- [ ] ECR scan-on-push
- [ ] Network security review
- [ ] Kubernetes security review
- [ ] IAM role review
- [ ] Security testing in CI/CD

---

## Troubleshooting

- [x] Troubleshoot Docker build failures
- [x] Troubleshoot Docker networking
- [x] Troubleshoot Kubernetes application failures
- [x] Create CrashLoopBackOff
- [x] Troubleshoot CrashLoopBackOff
- [ ] Create ImagePullBackOff
- [ ] Troubleshoot ImagePullBackOff
- [x] Break Kubernetes Service configuration
- [x] Troubleshoot deployment problems
- [x] Practice Kubernetes rollback
- [ ] Troubleshoot database connectivity
- [ ] Troubleshoot ECR authentication
- [x] Troubleshoot GitHub OIDC authentication
- [ ] Troubleshoot EKS deployment failures
- [ ] Document common troubleshooting workflows

---

## Documentation

- [x] Create project README
- [x] Document application architecture
- [x] Document Docker workflow
- [x] Document CI/CD workflow
- [x] Document GitHub OIDC authentication
- [x] Document IAM role and trust relationship
- [x] Document ECR integration
- [x] Document Kubernetes fundamentals
- [x] Document Blue-Green deployment
- [ ] Document AWS architecture
- [ ] Document EKS architecture
- [ ] Document Terraform architecture
- [ ] Document observability architecture
- [ ] Add architecture diagrams
- [ ] Add deployment runbook
- [ ] Add troubleshooting runbook

---

## Future Improvements

- [ ] Replace `ci` image tag with Git commit SHA
- [ ] Implement image promotion between environments
- [ ] Add development/staging/production environments
- [ ] Add automated deployment approvals
- [ ] Add smoke tests after deployment
- [ ] Add deployment rollback automation
- [ ] Add dependency scanning
- [ ] Add infrastructure security scanning
- [ ] Improve application observability
- [ ] Add production-style monitoring dashboards