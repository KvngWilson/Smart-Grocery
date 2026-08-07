output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "vpc_name" {
  description = "VPC network name"
  value       = module.vpc.vpc_name
}

output "subnet_name" {
  description = "Subnet name"
  value       = module.vpc.subnet_name
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "container_registry" {
  description = "Container registry URL"
  value       = "${var.container_registry}/${var.project_id}"
}

output "load_balancer_ip" {
  description = "Load balancer IP address (if available)"
  value       = try(kubernetes_service.client.status[0].load_balancer[0].ingress[0].ip, "pending")
}

output "application_url" {
  description = "Application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${try(kubernetes_service.client.status[0].load_balancer[0].ingress[0].ip, "pending")}"
}

output "next_steps" {
  description = "Next steps after deployment"
  value = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════╗
    ║           Smart Grocery - GCP Deployment Complete!            ║
    ╚════════════════════════════════════════════════════════════════╝
    
    📋 Next Steps:
    
    1. Configure kubectl:
       ${module.gke.kubectl_config_command}
    
    2. Build and push Docker images:
       docker build -f Dockerfile.server -t ${var.container_registry}/${var.project_id}/smart-grocery-server:latest .
       docker build -f Dockerfile.client -t ${var.container_registry}/${var.project_id}/smart-grocery-client:latest .
       docker push ${var.container_registry}/${var.project_id}/smart-grocery-server:latest
       docker push ${var.container_registry}/${var.project_id}/smart-grocery-client:latest
    
    3. Deploy the application:
       kubectl apply -k k8s/
    
    4. Check deployment status:
       kubectl get pods -n smart-grocery
       kubectl get svc -n smart-grocery
    
    5. Access your application:
       ${var.domain_name != "" ? "https://${var.domain_name}" : "http://[LOAD_BALANCER_IP]"}
    
    📊 Monitoring:
       https://console.cloud.google.com/kubernetes/workload?project=${var.project_id}
    
    🔐 Security:
       - Private nodes enabled: ${var.enable_private_nodes}
       - Network policies: Enabled
       - Workload Identity: Enabled
    
  EOT
}
