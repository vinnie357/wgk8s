resource "helm_release" "redis" {
  name             = "redis"
  # wait for deployment to be ready
  wait_for_jobs    = false
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  namespace        = var.namespace
  create_namespace = true
  set {
    name  = "global.redis.password"
    value = random_password.redis_password.result
  }
  set {
    name  = "master.persistence.enabled"
    value = "true"
  }
  ## optional set default storage class
  #   set {
  #     #  default
  #     name  = "global.storageClass"
  #     value = "encrypted-storage"
  #   }

}
