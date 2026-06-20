# Damolak Assessment

# MiniShop – Production-Ready DevOps Deployment

## Overview

MiniShop is a containerized full-stack application designed to demonstrate real-world DevOps practices, including:

- Docker-based microservice-style architecture
- CI/CD-ready project structure
- Observability (metrics, logs, and tracing)
- Monitoring with Prometheus and Grafana
- OpenTelemetry Collector for telemetry export
- Centralized logging with Loki and Promtail
- Backend instrumentation using FastAPI middleware
- Amazon RDS for MySQL data persistence
- AWS Secrets Manager for secure credential storage
- AWS Certificate Manager (ACM) for HTTPS certificates
- Amazon Elastic Container Registry (ECR) was used as the private container registry for storing Docker images.
- GitHub Actions builds the frontend and backend Docker images and pushes them to ECR.
- The EC2 deployment server pulls the latest images directly from ECR during deployment.
- IAM roles and policies are used to securely authenticate to ECR without hardcoded credentials.
- Image versioning and tagging (`semver style` and commit SHA) enable easy rollbacks and consistent deployments.
- ECR provides a secure, highly available, and fully managed solution for container image storage.
- Implemented AWS authentication in GitHub Actions using OpenID Connect (OIDC), allowing secure, passwordless access to AWS services.
- Eliminated the use of long-lived AWS access keys by using temporary credentials issued via AWS STS.
- Configured an IAM role with a trust relationship to GitHub’s OIDC provider for least-privilege access.
- Enabled secure CI/CD deployments to AWS services like EC2 (SSM) and Amazon ECR without storing sensitive credentials in GitHub Secrets.


---

## Architecture

```text
Internet
   ↓
Application Load Balancer (HTTPS)
   ↓
------------------------------------------------
EC2 VM (Docker Host)
 ├── Frontend (Nginx - :80)
 ├── Backend (FastAPI - :8000)
 ├── Prometheus (:9090)
 ├── Grafana (:3001)
 ├── Loki (:3100)
 ├── Promtail
 └── OpenTelemetry Collector (:4317/:4318)
------------------------------------------------
   ↓
Amazon RDS for MySQL (Private Subnet)
```

---

## Services

### Frontend

Static website served through Nginx.

**URL:**  
https://app.delightdavid.online

---

### Backend (FastAPI)

REST API with built-in observability instrumentation.

#### Endpoints

##### Health Check

- `GET /health`

##### Metrics (Prometheus)

- `GET /metrics`

##### Products

- `GET /products`
- `POST /products`
- `PUT /products/{id}`
- `DELETE /products/{id}`

##### Users

- `POST /users/register`
- `POST /users/login`
- `GET /users/me`

**Base URL:**  
https://delightdavid.online

---

### Database (Amazon RDS for MySQL)

- Managed MySQL database hosted on Amazon RDS
- Stores users, products, orders, and application data
- Deployed in private subnets for enhanced security
- Automated backups and snapshots enabled
- Multi-AZ deployment supported for high availability
- Credentials securely retrieved from AWS Secrets Manager

---

### Prometheus

- Scrapes backend and OpenTelemetry Collector metrics
- Collects HTTP request statistics, latency, and system metrics

**URL:**  
https://prometheus.delightdavid.online

---

### Grafana

- Visualizes metrics from Prometheus
- Displays logs from Loki
- Provides operational dashboards and alerts

**URL:**  
https://grafana.delightdavid.online

---

### Loki

- Centralized log storage system
- Receives logs from Promtail
- Queried through Grafana using LogQL

---

### Promtail

- Collects Docker container logs
- Ships logs to Loki

---

### OpenTelemetry Collector

- Receives telemetry data from the backend
- Processes and exports metrics to Prometheus
- Supports both gRPC and HTTP ingestion

---

## Observability Flow

### Metrics Flow

```text
FastAPI Backend
      ↓
OpenTelemetry Collector
      ↓
Prometheus
      ↓
Grafana
```

### Logs Flow

```text
Docker Containers
      ↓
Promtail
      ↓
Loki
      ↓
Grafana
```

---

## Run the Project

### 1. Clone the Repository

```bash
git clone <repo-url>
cd project
```

### 2. Configure Environment Variables

```bash
cp .env.example .env
```

Update `.env` with:

- RDS endpoint
- MySQL database name
- Secrets Manager secret name
- AWS region

### 3. Start Services

```bash
docker compose up --build -d
```

---

## Access URLs

| Service | URL |
|--------|-----|
| Application | https://delightdavid.online |
| Prometheus | https://prometheus.delightdavid.online |
| Grafana | https://grafana.delightdavid.online |

---

## Metrics Collected

The backend exposes the following Prometheus metrics:

- `http_requests_total`
- `http_request_duration_seconds`
- `in_progress_requests`
- `python_gc_objects_collected_total`
- `process_cpu_seconds_total`
- `process_resident_memory_bytes`

---

## CI/CD Pipeline

Implemented using GitHub Actions.

### Pipeline Stages

1. Build Docker images
2. Run automated tests
3. Push images to container registry
4. Deploy to EC2 via AWS Systems Manager Run Command
5. Perform health checks
6. Support rollback to previous version


# Infrastructure Pipeline Overview

## Terraform (Infrastructure as Code)

- Used to provision and manage AWS infrastructure in a declarative way  
- Defines resources such as VPC, subnets, EC2 instances, security groups, RDS, and Auto Scaling groups  
- Pipeline steps include:
  - Terraform init to configure backend and download providers  
  - Terraform validate and plan to check configuration and preview changes  
  - Terraform apply to create or update infrastructure in AWS  
  - Drift detection
  - pipeline notifies and fails if any resource is to be deleted
- Uses remote state storage in S3 for consistency across runs  
- Uses DynamoDB for state locking to prevent concurrent modifications  
- Ensures infrastructure is version-controlled, repeatable, and auditable  


 

## CI/CD Pipeline Flow

- Code is pushed to GitHub repository  
- Pipeline is triggered with manual approval 
- Terraform provisions or updates AWS infrastructure  
- Ansible configures the provisioned servers  
- Application is deployed and becomes available through the infrastructure stack  

---

## Logging

Logs are collected using:

- Docker container logs
- Promtail log shipper
- Loki log storage
- Grafana visualization

### Example LogQL Query

```logql
{job="docker-containers"}
```

---

## Security Notes

- Amazon RDS is deployed in private subnets with no public access
- Database credentials are stored in AWS Secrets Manager
- Security groups restrict database access to the backend host only
- Internal Docker networking is used for service-to-service communication
- HTTPS is enabled using certificates from AWS Certificate Manager
- IAM roles are used instead of hardcoded AWS credentials

---

## DevOps Concepts Demonstrated

- Docker containerization
- Multi-service orchestration with Docker Compose
- Infrastructure as Code using Terraform
- Remote Terraform state management
- Secure VPC design with public and private subnets
- Application Load Balancer configuration
- HTTPS termination with AWS Certificate Manager
- Managed database deployment with Amazon RDS for MySQL
- Secrets management with AWS Secrets Manager
- CI/CD with GitHub Actions
- Monitoring with Prometheus and Grafana
- Centralized logging with Loki and Promtail
- OpenTelemetry instrumentation
- Auto Scaling implementation

---

## Summary

This project simulates a production-grade DevOps environment featuring:

- Scalable and secure cloud architecture
- Managed MySQL database on Amazon RDS
- Full observability stack (metrics, logs, and tracing)
- Automated CI/CD deployment pipeline
- Infrastructure as Code with Terraform
- HTTPS-enabled applications and monitoring endpoints

---

## Author

**Chukwuagoziem Delight David**  
DevOps Engineer Practical Challenge Submission.


