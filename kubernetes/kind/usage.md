
```bash
brew install kind
brew install helm


mkdir -p /tmp/volumes

# Create a local cluster
# kind delete cluster -n local
# kind create cluster \
#   --name local \
#   --config kind-cluster-config.yaml

kind create cluster \
  --name local \
  --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        system-reserved: cpu=6,memory=12Gi
  extraPortMappings:
  - containerPort: 30000
    hostPort: 80
    listenAddress: "127.0.0.1"
    protocol: TCP
  extraMounts:
    - hostPath: /tmp/volumes
      containerPath: /volumes
    - hostPath: "$HOME/.ssl/SK_SSL.crt"
      containerPath: /usr/local/share/ca-certificates/SK_SSL.crt
# - role: worker
EOF

docker exec local-control-plane update-ca-certificates

kubectl label --overwrite nodes `kubectl get no -o jsonpath='{.items[0].metadata.name}'` nodetype=worker devicetype=cpu
# kubectl label --overwrite nodes `kubectl get no -o jsonpath='{.items[1].metadata.name}'` nodetype=worker devicetype=cpu

kubectl config current-context  # kind-local

# Install Istio
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

kubectl create namespace istio-system

helm upgrade --install istio-base \
    istio/base \
    --version "1.18.0" \
    -n istio-system

helm upgrade --install istio-istiod \
    istio/istiod \
    --version "1.18.0" \
    -n istio-system

helm upgrade --install istio-gateway \
    istio/gateway \
    --version "1.18.0" \
    -n istio-system \
    -f istio-values-kind.yaml \
    --wait


DB_USERNAME="test"
DB_PASSWORD="test"

kubectl create ns app


helm upgrade --install systemdb \
  oci://registry-1.docker.io/bitnamicharts/postgresql \
  -n app \
  --set global.postgresql.auth.username=$DB_USERNAME \
  --set global.postgresql.auth.password=$DB_PASSWORD \
  --set global.postgresql.auth.database=backend \
  --set primary.persistence.enabled=false \
  --set readReplicas.persistence.enabled=false \
  --wait

OPENSEARCH_USERNAME="admin"
OPENSEARCH_PASSWORD="admin"


kubectl create secret generic systemdb-cred \
  -n corus \
  --from-literal=username="$DB_USERNAME" \
  --from-literal=password="$DB_PASSWORD"

kubectl create secret generic es-cred \
  -n corus \
  --from-literal=username="$OPENSEARCH_USERNAME" \
  --from-literal=password="$OPENSEARCH_PASSWORD"

kind load docker-image \
  --name local \
<image>:<tag>


kubectl create ns runner

kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f httpbin.yaml

