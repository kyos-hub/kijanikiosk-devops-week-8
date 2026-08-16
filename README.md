KijaniKiosk Production Deployment Pipeline (Week 8)
Overview

This project implements a complete Production Deployment Pipeline for the KijaniKiosk Payments Service. The goal is to demonstrate a reliable deployment strategy using Blue/Green deployments, automatic rollback, Docker containerization, and Kubernetes orchestration while providing evidence and documentation for each stage.

The solution satisfies the Week 8 DevOps requirements by proving that deployments can be performed with minimal downtime, automatically recover from failures, and be deployed as scalable containers.

Objectives
Implement Blue/Green deployment
Automatically rollback failed deployments in under 90 seconds
Containerize the application using Docker
Deploy the application to Kubernetes
Demonstrate Kubernetes self-healing
Produce deployment evidence and operational documentation
Repository Structure
deployment-pipeline/
│
├── bluegreen/
│   ├── demo-script.md
│   ├── kk-payments-slo.md
│   ├── post-incident-review.md
│   ├── rollback-evidence.txt
│   └── switch-cycle.log
│
├── containers/
│   ├── Dockerfile.production
│   ├── .dockerignore
│   ├── build-verification.txt
│   ├── deploy-output.txt
│   ├── kk-payments-deployment.yaml
│   ├── kk-payments-service.yaml
│   ├── registry-push.txt
│   ├── self-healing-rerun.txt
│   └── service-output.txt
│
└── comparison.md
Technologies Used
Docker
Kubernetes (Minikube)
Node.js
Nginx
Ubuntu Linux
Bash
Git & GitHub
Blue/Green Deployment

The Blue/Green deployment pipeline provides zero-downtime releases by maintaining two production environments.

Workflow
Deploy new version to Green
Verify Green health
Switch production traffic
Monitor deployment
Detect failures automatically
Roll back to Blue if necessary

Evidence is provided in:

switch-cycle.log
rollback-evidence.txt
Automatic Rollback

The deployment monitor continuously checks the health of the active environment.

If multiple consecutive health checks fail:

Production traffic is redirected to the previous environment
Service availability is restored automatically
No manual intervention is required

The rollback duration is recorded in:

deployment-pipeline/bluegreen/rollback-evidence.txt
Docker Containerization

The application is packaged using a production-ready multi-stage Docker build.

Features include:

Multi-stage build
Non-root execution (kijani user)
HEALTHCHECK
Production dependencies only
Optimized image size
Exec-form CMD

Build verification is available in:

deployment-pipeline/containers/build-verification.txt
Kubernetes Deployment

The application is deployed as a Kubernetes Deployment with:

Two replicas
Resource requests and limits
ImagePullSecrets
NodePort Service
Automatic self-healing

Deployment manifests:

kk-payments-deployment.yaml
kk-payments-service.yaml
Self-Healing Demonstration

The project demonstrates Kubernetes self-healing by:

Deleting a running Pod
Kubernetes automatically creating a replacement
Recording recovery time

Evidence is stored in:

deployment-pipeline/containers/self-healing-rerun.txt
Service Verification

The deployment was verified using:

Pod status
Service endpoints
Health endpoint
NodePort access
In-cluster DNS resolution

Evidence:

deployment-pipeline/containers/service-output.txt
Documentation

The project includes:

Service Level Indicators (SLIs)
Service Level Objectives (SLOs)
Incident Review
Blue/Green switch evidence
Rollback evidence
Kubernetes deployment evidence
Executive comparison document
Board presentation script
Running the Project
Build Docker Image
docker build --no-cache -f deployment-pipeline/containers/Dockerfile.production -t kk-payments .
Deploy to Kubernetes
kubectl apply -f deployment-pipeline/containers/kk-payments-deployment.yaml
kubectl apply -f deployment-pipeline/containers/kk-payments-service.yaml
Verify Deployment
kubectl get pods
kubectl get svc
kubectl get endpoints
Project Deliverables
✅ Blue/Green Deployment
✅ Automatic Rollback
✅ Production Docker Image
✅ Kubernetes Deployment
✅ Kubernetes Service
✅ Registry Push Evidence
✅ Build Verification
✅ Self-Healing Demonstration
✅ SLI/SLO Documentation
✅ Incident Review
✅ Executive Comparison
✅ Board Demonstration Script
Learning Outcomes

This project demonstrates practical experience with:

Production deployment strategies
Blue/Green deployments
Automated rollback
Docker image optimization
Kubernetes deployments
Container orchestration
Infrastructure reliability
DevOps best practices
Production monitoring
Incident response
Author

Alan Kiptoo

License

This project was developed for the KijaniKiosk DevOps Week 8 Independent Project and is intended for educational purposes.
