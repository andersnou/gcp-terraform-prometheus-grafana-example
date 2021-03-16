resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"
    labels = {
      name = "grafana"
    }
    namespace = "monitor"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = "grafana"
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
          name = "grafana"
        }
      }
      spec {
        container {
          image = "grafana/grafana:latest"
          image_pull_policy = "IfNotPresent"
          name = "grafana"

          port {
            container_port = 3000
            protocol = "TCP"
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          volume_mount {
            name = "data"
            mount_path = "/var/lib/grafana"
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