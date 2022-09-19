# run services with helm

## export vars

```bash
cd terraform/constellation
export TF_VAR_namespace="mynamespace"
export TF_VAR_kubeconfig_path=$(realpath ../../constellation-admin.conf)
```
