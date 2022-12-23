# Kind

See: https://github.com/kubernetes-sigs/kind

## Installation

```bash
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.17.0/kind-$(uname)-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## Create a Kind Cluster

```bash
kind create cluster  --name kind-local
#kind delete cluster
```

```log
❯ kind create cluster  --name kind-local
Creating cluster "kind-local" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-kind-local"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-local

Thanks for using kind! 😊
```

## Install an app using `helm`

```bash
helm repo add kubernetes-dashboard \
  https://kubernetes.github.io/dashboard/

helm install dashboard kubernetes-dashboard/kubernetes-dashboard \
  -n kubernetes-dashboard \
  --create-namespace
```


```log
❯ helm install dashboard kubernetes-dashboard/kubernetes-dashboard -n kubernetes-dashboard --create-namespace
NAME: dashboard
LAST DEPLOYED: Fri Dec 23 13:42:38 2022
NAMESPACE: kubernetes-dashboard
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*********************************************************************************
*** PLEASE BE PATIENT: kubernetes-dashboard may take a few minutes to install ***
*********************************************************************************

Get the Kubernetes Dashboard URL by running:
  export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=dashboard" -o jsonpath="{.items[0].metadata.name}")
  echo https://127.0.0.1:8443/
  kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:8443
```

