# config for gcp account

### Install and Authenticate the GCP SDK Command Line Tools

**If you are using [Google Cloud](https://cloud.google.com/shell), you already have `gcloud` set up, and you can safely skip this step.**

To install the GCP SDK Command Line Tools, follow the installation instructions for your specific operating system:

- [Linux](https://cloud.google.com/sdk/docs/downloads-interactive#linux)
- [MacOS](https://cloud.google.com/sdk/docs/downloads-interactive#mac)
- [Windows](https://cloud.google.com/sdk/docs/downloads-interactive#windows)

After installation, authenticate `gcloud` with the following command:

```console
gcloud auth login
```

## Create a New Project

Generate a project ID with the following command:

```console
export GOOGLE_PROJECT="wgk8s-$(cat /dev/random | head -c 5 | xxd -p)"
```

Using that project ID, create a new GCP [project](https://cloud.google.com/docs/overview#projects):

```console
gcloud projects create $GOOGLE_PROJECT
```

And then set your `gcloud` config to use that project:

```console
gcloud config set project $GOOGLE_PROJECT
```

### Link Billing Account to Project

Next, let's link a billing account to that project. To determine what billing accounts are available, run the following command:

```console
gcloud alpha billing accounts list
```

Locate the `ACCOUNT_ID` for the billing account you want to use, and set the `GOOGLE_BILLING_ACCOUNT` environment variable. Replace the `XXXXXXX` with the `ACCOUNT_ID` you located with the previous command output:

```console
export GOOGLE_BILLING_ACCOUNT="XXXXXXX"
```

So we can link the `GOOGLE_BILLING_ACCOUNT` with the previously created `GOOGLE_PROJECT`:

```console
gcloud alpha billing projects link "$GOOGLE_PROJECT" --billing-account "$GOOGLE_BILLING_ACCOUNT"
```

### Enable Compute API

In order to deploy VMs to the project, we need to enable the compute API:

```console
gcloud services enable compute.googleapis.com
```

### Create Service Account

Finally, let's create a Service Account user and its `gcpServiceAccountKey.json` credentials file:

```console
gcloud iam service-accounts create wgk8s-sa \
    --display-name "wgk8s Service Account" \
    --description "Service account to use with wgk8s"
```

```console
gcloud projects add-iam-policy-binding "$GOOGLE_PROJECT" \
  --member serviceAccount:"wgk8s-sa@$GOOGLE_PROJECT.iam.gserviceaccount.com" \
  --role roles/editor
```

```console
gcloud iam service-accounts keys create gcpServiceAccountKey.json \
    --iam-account "wgk8s-sa@$GOOGLE_PROJECT.iam.gserviceaccount.com"
```

> ⚠️ **Warning**
>
> The `gcpServiceAccountKey.json` credentials gives privileged access to this GCP project. Be careful to avoid leaking these credentials by accidentally committing them to version control systems such as `git`, or storing them where they are visible to others. In general, storing these credentials on an individually operated, private computer (like your laptop) or in your own GCP cloud shell is acceptable for testing purposes. For production use, or for teams, use a secrets management system like HashiCorp [Vault](https://www.vaultproject.io/). For this tutorial's purposes, we'll be storing the `account.json` credentials on disk in the cloud shell.

Now set the _full path_ of the newly created `gcpServiceAccountKey.json` file as `GOOGLE_APPLICATION_CREDENTIALS` environment variable.

```console
export GOOGLE_APPLICATION_CREDENTIALS=$(realpath gcpServiceAccountKey.json)
```

### Ensure Required Environment Variables Are Set

Before moving onto the next steps, ensure the following environment variables are set:

- `GOOGLE_PROJECT` with your selected GCP project ID.
- `GOOGLE_APPLICATION_CREDENTIALS` with the _full path_ to the Terraform Service Account `gcpServiceAccountKey.json` credentials file created in the last step.

```bash
echo $GOOGLE_PROJECT
echo $GOOGLE_APPLICATION_CREDENTIALS
```

### genrate config for gcp

```
constellation config generate gcp
```

### configure service account for constellation cluster

https://docs.edgeless.systems/constellation/getting-started/first-steps

```bash
# enter name of service account here
SERVICE_ACCOUNT_ID=constellation
# enter project id here
PROJECT_ID=${GOOGLE_PROJECT}
SERVICE_ACCOUNT_EMAIL=${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com
gcloud iam service-accounts create "${SERVICE_ACCOUNT_ID}" --description="Service account used inside Constellation" --display-name="Constellation service account" --project="${PROJECT_ID}"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role='roles/compute.instanceAdmin.v1'
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role='roles/compute.networkAdmin'
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role='roles/compute.securityAdmin'
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role='roles/compute.storageAdmin'
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" --role='roles/iam.serviceAccountUser'
gcloud iam service-accounts keys create constellationGcpServiceAccountKey.json --iam-account="${SERVICE_ACCOUNT_EMAIL}"
echo "project: ${PROJECT_ID}"
echo "serviceAccountKeyPath: $(realpath constellationGcpServiceAccountKey.json)"
```

### set node sizes

```bash
constellation config instance-types
constellation config fetch-measurements
```

### create cluster

```bash
constellation create --control-plane-nodes 1 --worker-nodes 1 -y
```

### init cluster

```bash
constellation init
```

### export kubeconf

```
export KUBECONFIG="$PWD/constellation-admin.conf"
```

### test with kubeproxy

```bash
# create app
kubectl apply -k github.com/BuoyantIO/emojivoto/kustomize/deployment
# test app
kubectl wait --for=condition=available --timeout=60s -n emojivoto --all deployments
kubectl -n emojivoto port-forward svc/web-svc 8080:80 &
curl http://localhost:8080
kill %1
```

### presistent storage

https://docs.edgeless.systems/constellation/workflows/storage

```bash
# csi driver
kubectl apply -k github.com/edgelesssys/constellation-gcp-compute-persistent-disk-csi-driver/deploy/kubernetes/overlays/edgeless/latest
# storage class with driver
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: encrypted-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: gcp.csi.confidential.cloud
parameters:
  type: pd-standard
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF
# persistent volume with storage-class
cat <<EOF | kubectl apply -f -
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-example
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: encrypted-storage
  resources:
    requests:
      storage: 20Gi
EOF
```

### optional set default storage class

```bash
kubectl get storageclass
# unset old and set new
#kubectl patch storageclass <name-of-old-default> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
#kubectl patch storageclass <name-of-new-default> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
# test with single pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  namespace: default
spec:
  containers:
  - name: web-server
    image: nginx
    volumeMounts:
    - mountPath: /var/lib/www/html
      name: mypvc
  volumes:
  - name: mypvc
    persistentVolumeClaim:
      claimName: pvc-example
      readOnly: false
EOF
```

### use with helm

```
cd terraform
terraform init
terraform plan
terraform apply
```

### destroy cluster

```bash
cd ..
constellation terminate
```

### Delete the Project

Finally, to completely delete the project:

gcloud projects delete $GOOGLE_PROJECT

> ### Alternative: Use the GUI
>
> If you prefer to delete the project using GCP's Cloud Console, follow this link to GCP's [Cloud Resource Manager](https://console.cloud.google.com/cloud-resource-manager).
