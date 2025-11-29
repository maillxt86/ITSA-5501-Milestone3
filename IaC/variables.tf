variable "namespace" {
  description = "Kubernetes namespace for the project"
  type        = string
  default     = "milestone3"
}

variable "nodeport" {
  description = "NodePort for accessing the service"
  type        = number
  default     = 30080
}
