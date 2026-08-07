# Production Environment Configuration
project_id  = "YOUR_GCP_PROJECT_ID"  # Replace with your GCP project ID
region      = "us-central1"
zone        = "us-central1-a"
environment = "prod"

# Cluster configuration
cluster_name     = "smart-grocery-prod-cluster"
gke_node_count   = 3
gke_machine_type = "e2-standard-2"
min_node_count   = 2
max_node_count   = 10

# Features
enable_autopilot        = false
enable_private_endpoint = false
enable_private_nodes    = true  # Private nodes for security
enable_backup           = true
enable_monitoring       = true
enable_ssl              = true

# Domain (optional - set your domain)
domain_name = ""  # e.g., "smart-grocery.yourdomain.com"

# Container registry
container_registry = "gcr.io"

# Tags
tags = {
  app         = "smart-grocery"
  environment = "production"
  managed_by  = "terraform"
  team        = "devops"
  cost_center = "engineering"
}
