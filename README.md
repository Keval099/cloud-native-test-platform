# Cloud Native Test Platform

A hands-on AWS cloud-native project demonstrating the complete software delivery lifecycle from application development to automated deployment, observability, and recovery.

> **Develop → Test → Containerize → Scan → Push → Provision → Deploy → Observe → Validate → Roll Back**

---

## Project Status

**Completed**

The project demonstrates a production-oriented cloud-native workflow using AWS, Docker, Kubernetes, Terraform, GitHub Actions, and CloudWatch.

---

## What This Project Demonstrates

This project was built to demonstrate practical experience across:

- Python / FastAPI
- Automated testing with Pytest
- Docker
- Amazon ECR
- Amazon EKS
- Kubernetes fundamentals
- Terraform
- AWS IAM
- GitHub Actions
- GitHub OIDC
- CI/CD
- Container security scanning with Trivy
- CloudWatch Container Insights
- CloudWatch Logs
- CloudWatch Metrics
- CloudWatch Dashboards
- CloudWatch Alarms
- Deployment validation
- Automated rollback

---

# Architecture

```text
                         GitHub Repository
                                |
                                |
                         GitHub Actions
                                |
              +-----------------+-----------------+
              |                                   |
         Pytest Tests                       Docker Build
              |                                   |
              |                                Trivy
              |                                   |
              +-----------------+-----------------+
                                |
                         GitHub OIDC
                                |
                         AWS IAM Role
                                |
                                v
                         Amazon ECR
                                |
                                |
                                v
                         Amazon EKS
                    +-----------+-----------+
                    |                       |
                 Node 1                  Node 2
                    |                       |
                 Pod 1                   Pod 2
                    |                       |
                    +-----------+-----------+
                                |
                         Kubernetes Service
                                |
                         FastAPI Application
                                |
                         /health and /
                                |
                                v
                     CloudWatch Observability
                    +-----------+-------------+
                    |                         |
                Logs/Metrics              Alarms
                    |                         |
                    +-----------+-------------+
                                |
                         CloudWatch Dashboard


---------------------The project demonstrates an end-to-end cloud-native delivery platform----------------
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
   +--> Trivy Scan
   |
   +--> ECR
   |
   v
Amazon EKS
   |
   +--> Kubernetes Deployment
   |
   +--> Kubernetes Service
   |
   v
FastAPI Application
   |
   +--> Health Checks
   |
   +--> Logs
   |
   +--> Metrics
   |
   v
CloudWatch
   |
   +--> Dashboard
   |
   +--> Alarms

Failed Deployment
        |
        v
Automatic Rollback
        |
        v
Healthy Application