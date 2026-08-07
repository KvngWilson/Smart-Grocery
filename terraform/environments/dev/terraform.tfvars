# Development Environment Configuration
project_id  = "steel-spirit-472822-i7"  # Replace with your GCP project ID
region      = "us-central1"
zone        = "us-central1-a"
environment = "dev"

# Cluster configuration
cluster_name     = "smart-grocery-dev-cluster"
gke_node_count   = 2
gke_machine_type = "e2-medium"
min_node_count   = 1
max_node_count   = 3

# Features
enable_autopilot        = false
enable_private_endpoint = false
enable_private_nodes    = false  # Set to false for easier access in dev
enable_backup           = false
enable_monitoring       = true
enable_ssl              = false

# Container registry
container_registry = "gcr.io"

# Tags
tags = {
  app         = "smart-grocery"
  environment = "development"
  managed_by  = "terraform"
  team        = "devops"
}
