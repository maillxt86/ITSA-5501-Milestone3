output "namespace" {
  value = var.namespace
}

output "service_nodeport" {
  value = var.nodeport
}

output "service_url" {
  value = "http://127.0.0.1:${var.nodeport}"
}
