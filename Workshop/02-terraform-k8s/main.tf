# Configure the Kind provider
provider "kind" {}

# Configure the Kubernetes provider
provider "kubernetes" {
  config_path    = kind_cluster.default.kubeconfig_path
  config_context = "kind-${kind_cluster.default.name}"
}

# Create Kind cluster
resource "kind_cluster" "default" {
  name           = var.cluster_name
  node_image     = "kindest/node:${var.kubernetes_version}"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    # Worker nodes
    dynamic "node" {
      for_each = range(var.worker_nodes)
      content {
        role = "worker"
      }
    }
  }
}

# Save kubeconfig to local file for easy access
resource "local_file" "kubeconfig" {
  content  = kind_cluster.default.kubeconfig
  filename = var.kubeconfig_path
  
  # Make sure the file is readable only by owner
  file_permission = "0600"
}
