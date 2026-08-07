# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  app_name    = var.app_name
}

# GKE Module
module "gke" {
  source = "./modules/gke"

  project_id                = var.project_id
  region                    = var.region
  zone                      = var.zone
  environment               = var.environment
  cluster_name              = var.cluster_name
  network                   = module.vpc.vpc_name
  subnetwork                = module.vpc.subnet_name
  
  node_count                = var.gke_node_count
  machine_type              = var.gke_machine_type
  min_node_count            = var.min_node_count
  max_node_count            = var.max_node_count
  
  enable_autopilot          = var.enable_autopilot
  enable_private_endpoint   = var.enable_private_endpoint
  enable_private_nodes      = var.enable_private_nodes
  master_ipv4_cidr_block    = var.master_ipv4_cidr_block
  
  enable_monitoring         = var.enable_monitoring
  tags                      = var.tags
}

# Enable required GCP APIs
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
  
  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"
  
  disable_on_destroy = false
}

# Artifact Registry for container images
resource "google_artifact_registry_repository" "docker" {
  count = var.container_registry == "artifact-registry" ? 1 : 0
  
  location      = var.region
  repository_id = "${var.app_name}-docker"
  description   = "Docker repository for ${var.app_name}"
  format        = "DOCKER"
  
  labels = var.tags
}

# Cloud Storage bucket for backups
resource "google_storage_bucket" "backups" {
  count = var.enable_backup ? 1 : 0
  
  name          = "${var.project_id}-${var.app_name}-backups"
  location      = var.region
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  labels = var.tags
}

# Kubernetes namespace
resource "kubernetes_namespace" "smart_grocery" {
  depends_on = [module.gke]
  
  metadata {
    name = var.app_name
    
    labels = {
      name        = var.app_name
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# Kubernetes ConfigMap
resource "kubernetes_config_map" "app_config" {
  depends_on = [kubernetes_namespace.smart_grocery]
  
  metadata {
    name      = "app-config"
    namespace = var.app_name
  }
  
  data = {
    REDIS_URL     = "redis://redis:6379"
    NODE_ENV      = var.environment
    API_BASE_URL  = "/api"
  }
}

# Kubernetes Service for Client (LoadBalancer)
resource "kubernetes_service" "client" {
  depends_on = [kubernetes_namespace.smart_grocery]
  
  metadata {
    name      = "client"
    namespace = var.app_name
    
    labels = {
      app = "client"
    }
  }
  
  spec {
    type = "LoadBalancer"
    
    selector = {
      app = "client"
    }
    
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }
  }
}

# Cloud Monitoring Dashboard
resource "google_monitoring_dashboard" "main" {
  count = var.enable_monitoring ? 1 : 0
  
  dashboard_json = jsonencode({
    displayName = "${var.app_name} Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Pod CPU Usage"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_container\" resource.labels.namespace_name=\"${var.app_name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Pod Memory Usage"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_container\" resource.labels.namespace_name=\"${var.app_name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
              }]
            }
          }
        }
      ]
    }
  })
}
