# KijaniKiosk Production Deployment Pipeline (Week 8)

## Overview

This project demonstrates a complete production deployment pipeline for the KijaniKiosk Payments Service. It implements a Blue/Green deployment strategy with automatic rollback, Docker containerization, and Kubernetes deployment. The project emphasizes reliability, fault recovery, and production-ready deployment practices while providing evidence for each implementation stage.

---

## Objectives

- Implement Blue/Green deployment.
- Perform automatic rollback when deployment health checks fail.
- Containerize the application using Docker.
- Deploy the application to Kubernetes.
- Demonstrate Kubernetes self-healing capabilities.
- Document deployment evidence and operational procedures.

---

## Repository Structure

```text
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
```

---

## Technologies Used

- Docker
- Kubernetes (Minikube)
- Node.js
- Nginx
- Ubuntu Linux
- Bash
- Git
- GitHub

---

## Blue/Green Deployment

The application uses a Blue/Green deployment strategy to minimize downtime during releases.

### Deployment Workflow

1. Deploy the new application version to the Green environment.
2. Verify that the Green environment is healthy.
3. Switch production traffic from Blue to Green.
4. Continuously monitor application health.
5. Automatically trigger rollback if failures are detected.
6. Restore production traffic to the previous stable environment.

Deployment evidence is available in:

- `deployment-pipeline/bluegreen/switch-cycle.log`
- `deployment-pipeline/bluegreen/rollback-evidence.txt`

---

## Automatic Rollback

The deployment monitor continuously checks the health of the active deployment.

If repeated health check failures occur:

- Production traffic is redirected to the previous environment.
- Service availability is restored automatically.
- No manual intervention is required.

Rollback evidence includes:

- Rollback trigger
- Environment switching
- Health verification
- Recovery time

---

## Docker Containerization

The application is packaged using a production-ready multi-stage Docker build.

### Features

- Multi-stage Docker build
- Optimized production image
- Non-root execution (`kijani` user)
- HEALTHCHECK support
- Production-only dependencies
- Exec-form CMD
- Optimized image size

Build verification is documented in:

`deployment-pipeline/containers/build-verification.txt`

---

## Kubernetes Deployment

The application is deployed to Kubernetes using a Deployment and a NodePort Service.

### Deployment Features

- Two application replicas
- Resource requests and limits
- ImagePullSecrets
- Rolling deployment
- Automatic restart
- Self-healing

Deployment manifests:

- `kk-payments-deployment.yaml`
- `kk-payments-service.yaml`

---

## Self-Healing Demonstration

The project demonstrates Kubernetes self-healing by deleting a running Pod and allowing Kubernetes to automatically create a replacement.

Evidence includes:

- Pod deletion
- Replacement Pod creation
- Recovery time
- Successful application health verification

Evidence file:

`deployment-pipeline/containers/self-healing-rerun.txt`

---

## Service Verification

The deployed application was verified through:

- Pod status
- Service endpoints
- NodePort connectivity
- Health endpoint responses
- Internal cluster DNS resolution

Verification evidence:

`deployment-pipeline/containers/service-output.txt`

---

## Documentation Included

This repository includes the following documentation:

- Blue/Green deployment evidence
- Automatic rollback evidence
- Service Level Indicators (SLIs)
- Service Level Objectives (SLOs)
- Incident review
- Kubernetes deployment verification
- Registry push verification
- Build verification
- Executive comparison report
- Board presentation demo script

---

## Running the Project

### Build the Docker Image

```bash
docker build --no-cache \
-f deployment-pipeline/containers/Dockerfile.production \
-t kk-payments .
```

### Deploy to Kubernetes

```bash
kubectl apply -f deployment-pipeline/containers/kk-payments-deployment.yaml

kubectl apply -f deployment-pipeline/containers/kk-payments-service.yaml
```

### Verify Deployment

```bash
kubectl get pods

kubectl get svc

kubectl get endpoints
```

---

## Project Deliverables

- Blue/Green Deployment
- Automated Rollback
- Production Docker Image
- Kubernetes Deployment
- Kubernetes Service
- Registry Push Verification
- Build Verification
- Self-Healing Demonstration
- SLI/SLO Documentation
- Incident Review
- Executive Comparison
- Board Demonstration Script

---

## Learning Outcomes

This project demonstrates practical experience in:

- Blue/Green deployment strategies
- Automated rollback
- Production deployment pipelines
- Docker image optimization
- Kubernetes deployment
- Container orchestration
- High availability
- Fault recovery
- Production monitoring
- DevOps best practices

---

## Author

**Alan Kiptoo**

---

## License

This project was developed for educational purposes as part of the KijaniKiosk DevOps Week 8 Production Deployment Pipeline project.
