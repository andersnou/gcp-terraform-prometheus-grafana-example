resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "prometheus"
    labels = {
      name = "prometheus"
    }
    namespace = "monitor"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "prometheus"
      }
    }
    strategy {
      rolling_update {
        max_surge = 1
        max_unavailable = 1
      }
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          name = "prometheus"
        }
      }
      spec {
        container {
          image = "prom/prometheus:latest"
          image_pull_policy = "IfNotPresent"
          name = "prometheus"

          port {
            container_port = 9090
            protocol = "TCP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
          volume_mount {
            name = "data"
            mount_path = "/prometheus"
            read_only = false
          }
        }
        security_context {}
        volume {
          name = "data"
          empty_dir {}
        }
      }
    }
  }
}
