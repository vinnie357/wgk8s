variable "kubeconfig_path" {
  description = "file path to k8s config"
  default     = "../../constellation-admin.conf"
}
variable "namespace" {
  description = "namespace to create resources in"
}
