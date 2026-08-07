# 🌩️ GCP Terraform Infrastructure Guide

## 📋 Overview

This guide covers provisioning complete Google Cloud Platform (GCP) infrastructure for the Smart Grocery Manager using Terraform with:

- **Google Kubernetes Engine (GKE)** - Managed Kubernetes cluster
- **VPC Network** - Private networking with NAT gateway
- **Cloud Load Balancer** - Auto-provisioned by GKE
- **Cloud Monitoring** - Observability and alerting
- **Cloud Storage** - Backup storage for Redis data
- **Artifact Registry** - Container image storage
- **IAM & Security** - Service accounts and permissions

---

## 🏗️ Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │           VPC Network (10.0.0.0/16)            │    │
│  │                                                 │    │
│  │  ┌───────────────────────────────────────┐     │    │
│  │  │  Subnet (10.0.1.0/24)                │     │    │
│  │  │                                       │     │    │
│  │  │  ┌─────────────────────────────┐     │     │    │
│  │  │  │  GKE Cluster (Regional)     │     │     │    │
│  │  │  │                             │     │     │    │
│  │  │  │  ┌──────────────────────┐   │     │     │    │
│  │  │  │  │   Node Pool          │   │     │     │    │
│  │  │  │  │   (2-10 nodes)       │   │     │     │    │
│  │  │  │  │   Auto-scaling       │   │     │     │    │
│  │  │  │  └──────────────────────┘   │     │     │    │
│  │  │  │                             │     │     │    │
│  │  │  │  Pods: 10.1.0.0/16          │     │     │    │
│  │  │  │  Services: 10.2.0.0/16      │     │     │    │
│  │  │  └─────────────────────────────┘     │     │    │
│  │  └───────────────────────────────────────┘     │    │
│  │                                                 │    │
│  │  Cloud NAT ──► Internet                        │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Cloud Load Balancer ──► GKE Services                   │
│  Cloud Monitoring & Logging                             │
│  Cloud Storage (Backups)                                │
│  Artifact Registry (Container Images)                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Terraform Structure

```
terraform/
├── main.tf                    # Main configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── providers.tf               # Provider configurations
├── .gitignore                # Ignore sensitive files
├── environments/              # Environment-specific configs
│   ├── dev/
│   │   └── terraform.tfvars  # Development variables
│   └── prod/
│       └── terraform.tfvars  # Production variables
└── modules/                   # Reusable modules
    ├── vpc/                   # VPC networking module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── gke/                   # GKE cluster module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🚀 Quick Start

### Prerequisites

1. **Install Required Tools:**
   ```bash
   # Google Cloud SDK
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Terraform
   # Download from: https://www.terraform.io/downloads
   
   # Verify installations
   gcloud --version
   terraform --version
   ```

2. **Authenticate with GCP:**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Create GCP Project (or use existing):**
   ```bash
   gcloud projects create YOUR-PROJECT-ID
   gcloud config set project YOUR-PROJECT-ID
   
   # Enable billing
   gcloud beta billing projects link YOUR-PROJECT-ID \
     --billing-account=YOUR-BILLING-ACCOUNT-ID
   ```

4. **Configure Terraform Variables:**
   ```bash
   # Edit the terraform.tfvars file
   nano terraform/environments/dev/terraform.tfvars
   
   # Replace YOUR_GCP_PROJECT_ID with your actual project ID
   ```

### Deploy Infrastructure

```bash
# Deploy to development environment
./gcp-deploy.sh dev

# Or deploy to production
./gcp-deploy.sh prod
```

This script will:
1. Initialize Terraform
2. Validate configuration
3. Show deployment plan
4. Apply infrastructure changes
5. Configure kubectl

---

## 📦 Build & Deploy Application

### 1. Build and Push Docker Images

```bash
./gcp-build-push.sh
```

This will:
- Build server and client Docker images
- Tag them for Google Container Registry (GCR)
- Push to `gcr.io/YOUR-PROJECT-ID/`

### 2. Update Kubernetes Manifests

Update image references in your Kubernetes manifests:

```yaml
# k8s/server-deployment.yaml
spec:
  containers:
  - name: server
    image: gcr.io/YOUR-PROJECT-ID/smart-grocery-server:latest

# k8s/client-deployment.yaml
spec:
  containers:
  - name: client
    image: gcr.io/YOUR-PROJECT-ID/smart-grocery-client:latest
```

### 3. Deploy to GKE

```bash
# Apply Kubernetes manifests
kubectl apply -k k8s/

# Check deployment status
kubectl get all -n smart-grocery

# Get external IP
kubectl get svc client -n smart-grocery -w
```

---

## 🔧 Configuration

### Environment Variables

Edit `terraform/environments/{dev|prod}/terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | Required |
| `region` | GCP Region | us-central1 |
| `zone` | GCP Zone | us-central1-a |
| `environment` | Environment name | dev/prod |
| `cluster_name` | GKE cluster name | smart-grocery-{env}-cluster |
| `gke_node_count` | Initial node count | 2 |
| `gke_machine_type` | Node machine type | e2-medium |
| `min_node_count` | Min nodes (autoscaling) | 1 |
| `max_node_count` | Max nodes (autoscaling) | 5 |
| `enable_autopilot` | Use GKE Autopilot | false |
| `enable_private_nodes` | Private node pool | true (prod) |
| `enable_monitoring` | Cloud Monitoring | true |
| `enable_backup` | Cloud Storage backups | true (prod) |

### Cost Optimization

**Development:**
- `gke_machine_type`: e2-medium ($24/month per node)
- `min_node_count`: 1
- `max_node_count`: 3
- **Estimated cost**: $50-100/month

**Production:**
- `gke_machine_type`: e2-standard-2 ($49/month per node)
- `min_node_count`: 2
- `max_node_count`: 10
- **Estimated cost**: $200-500/month (depending on load)

---

## 📊 Terraform Commands

### View Current State

```bash
cd terraform

# Show current infrastructure
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show module.gke.google_container_cluster.primary
```

### Update Infrastructure

```bash
# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"

# Apply specific resource
terraform apply -target=module.gke -var-file="environments/dev/terraform.tfvars"
```

### Import Existing Resources

```bash
# Import existing GKE cluster
terraform import \
  -var-file="environments/dev/terraform.tfvars" \
  module.gke.google_container_cluster.primary \
  projects/PROJECT_ID/locations/REGION/clusters/CLUSTER_NAME
```

### Destroy Infrastructure

```bash
# Using script (recommended)
./gcp-destroy.sh dev

# Or manually
cd terraform
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

---

## 🛡️ Security Features

### Network Security
- ✅ Private node IPs (optional)
- ✅ Private GKE control plane (optional)
- ✅ Cloud NAT for outbound traffic
- ✅ Firewall rules for internal communication
- ✅ Network policies enabled

### Identity & Access
- ✅ Workload Identity enabled
- ✅ Custom service accounts with minimal permissions
- ✅ Node service accounts with specific roles

### Cluster Security
- ✅ Binary authorization
- ✅ Shielded GKE nodes
- ✅ Secure boot enabled
- ✅ Automatic node upgrades
- ✅ Automatic node repairs

### Monitoring & Compliance
- ✅ Cloud Logging integration
- ✅ Cloud Monitoring integration
- ✅ Audit logs enabled
- ✅ Resource labels for tracking

---

## 📈 Monitoring & Operations

### View Cluster in Console

```bash
# Open GKE dashboard
echo "https://console.cloud.google.com/kubernetes/workload?project=$(gcloud config get-value project)"

# Open monitoring dashboard
echo "https://console.cloud.google.com/monitoring?project=$(gcloud config get-value project)"
```

### Cloud Monitoring

Terraform automatically creates a monitoring dashboard with:
- Pod CPU usage
- Pod memory usage
- Request rates
- Error rates

### View Logs

```bash
# GKE cluster logs
gcloud logging read "resource.type=k8s_cluster" --limit 50

# Application logs
gcloud logging read "resource.labels.namespace_name=smart-grocery" --limit 50

# Filter by severity
gcloud logging read "severity>=ERROR AND resource.labels.namespace_name=smart-grocery"
```

### Alerts (Optional)

Create alert policies in Cloud Monitoring:

```bash
# CPU usage alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Usage" \
  --condition-display-name="CPU > 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s
```

---

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Deploy to GCP
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Build & Push Images
        run: ./gcp-build-push.sh
      
      - name: Deploy to GKE
        run: |
          gcloud container clusters get-credentials CLUSTER_NAME --region REGION
          kubectl apply -k k8s/
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  image: google/cloud-sdk:alpine
  script:
    - echo $GCP_SA_KEY | base64 -d > ${HOME}/gcloud-service-key.json
    - gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json
    - gcloud config set project $GCP_PROJECT_ID
    - ./gcp-build-push.sh
    - gcloud container clusters get-credentials CLUSTER_NAME --region REGION
    - kubectl apply -k k8s/
  only:
    - main
```

---

## 💰 Cost Management

### View Current Costs

```bash
# View billing for project
gcloud billing projects describe $(gcloud config get-value project)

# Estimate costs
# Use: https://cloud.google.com/products/calculator
```

### Cost Optimization Tips

1. **Use Preemptible Nodes** (development only):
   ```hcl
   preemptible = true  # In gke/main.tf
   ```
   Saves ~80% but nodes can be terminated

2. **Use Autopilot Mode**:
   ```hcl
   enable_autopilot = true
   ```
   Pay only for pod resources

3. **Right-size Nodes**:
   - Development: e2-micro or e2-small
   - Production: e2-medium or e2-standard-2

4. **Enable Autoscaling**:
   - Nodes scale down when idle
   - Set appropriate min/max values

5. **Use Committed Use Discounts**:
   - 1-year: 37% discount
   - 3-year: 55% discount

### Budget Alerts

```bash
# Create budget alert
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Smart Grocery Budget" \
  --budget-amount=100 \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90
```

---

## 🔍 Troubleshooting

### Terraform Errors

**Error: Project not found**
```bash
# Verify project exists
gcloud projects list

# Set correct project
gcloud config set project YOUR-PROJECT-ID
```

**Error: API not enabled**
```bash
# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

**Error: Insufficient permissions**
```bash
# Check your permissions
gcloud projects get-iam-policy $(gcloud config get-value project)

# Required roles:
# - roles/container.admin
# - roles/compute.admin
# - roles/iam.serviceAccountAdmin
```

### GKE Connection Issues

**Cannot connect to cluster**
```bash
# Get credentials again
gcloud container clusters get-credentials CLUSTER_NAME --region REGION

# Verify kubectl context
kubectl config current-context

# Test connection
kubectl cluster-info
```

**Pods not starting**
```bash
# Check pod events
kubectl describe pod POD_NAME -n smart-grocery

# Check node status
kubectl get nodes

# Check resource quotas
kubectl describe resourcequota -n smart-grocery
```

### Image Pull Errors

```bash
# Verify images exist
gcloud container images list --repository=gcr.io/PROJECT_ID

# Configure GKE to pull from GCR
kubectl create secret docker-registry gcr-json-key \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat ~/gcloud-service-key.json)" \
  --docker-email=user@example.com \
  -n smart-grocery
```

---

## 📚 Additional Resources

### Documentation
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)

### Tutorials
- [GKE Quickstart](https://cloud.google.com/kubernetes-engine/docs/quickstart)
- [Terraform GCP Tutorial](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build)

### Cost Calculators
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [GKE Cost Estimator](https://cloud.google.com/products/calculator/#id=6d866c0e-b928-4786-b2cd-f5bf8b5b1b0e)

---

## 🎓 Next Steps

1. **Deploy infrastructure**: `./gcp-deploy.sh dev`
2. **Build images**: `./gcp-build-push.sh`
3. **Deploy application**: `kubectl apply -k k8s/`
4. **Set up monitoring**: Configure Cloud Monitoring alerts
5. **Configure CI/CD**: Automate deployments
6. **Add custom domain**: Configure Cloud DNS and SSL
7. **Set up backups**: Automate Redis backup to Cloud Storage
8. **Implement disaster recovery**: Multi-region setup

---

Your Smart Grocery Manager is now ready for enterprise-grade deployment on Google Cloud Platform! 🚀
