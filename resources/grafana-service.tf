resource "kubernetes_service" "grafana_service" {
  metadata {
    name = "grafana"
    namespace = "monitor"
  }
  spec {
    selector = {
      name = "grafana"
    }
    port {
      port = 3000
      protocol = "TCP"
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}
