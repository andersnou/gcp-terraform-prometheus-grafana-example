resource "kubernetes_service" "prometheus_service" {
  metadata {
    name = "prometheus"
    namespace = "monitor"
  }
  spec {
    selector = {
      name = "prometheus"
    }
    port {
      port = 9090
      protocol = "TCP"
      target_port = 9090
    }
    type = "LoadBalancer"
  }
}
