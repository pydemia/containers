# KF Serving with creating an inference cluster

Refer to [Integrating HTTP(S) Load Balancing with Cloud Run for Anthos on Google Cloud](https://cloud.google.com/solutions/integrating-https-load-balancing-with-istio-and-cloud-run-for-anthos-deployed-on-gke)

## 1. Create a cluster, which has `HTTP LoadBalancer`, `Istio`, `Knative`

**Info**: `addons Istio` and install `Knative` manually:It is not working.
Install `CloudRun` to bypass the problem

```bash
CLUSTER_NM=kfserving-sklearn
ZONE=us-central1-f
gcloud beta container clusters create $CLUSTER_NM \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio,CloudRun \
    --istio-config=auth=MTLS_PERMISSIVE \
    --cluster-version=1.15.9-gke.24 \
    --enable-ip-alias \
    --enable-stackdriver-kubernetes \
    --machine-type n1-standard-2 \
    --zone $ZONE \
    --no-enable-autoupgrade \
    --metadata disable-legacy-endpoints=true
```

Show the `current-context`:
```bash
kubectl config current-context
```

or select it:

```bash
gcloud container clusters get-credentials $CLUSTER_NM \
  --region $ZONE
  #--project ds-ai-platform
```

## 2. Set `HTTPLoadBalancer`

* Handling health check requests
```bash
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: health
  namespace: knative-serving
spec:
  gateways:
  - gke-system-gateway
  hosts:
  - "*"
  http:
  - match:
    - headers:
        user-agent:
          prefix: GoogleHC
      method:
        exact: GET
      uri:
        exact: /
    rewrite:
      authority: istio-ingress.gke-system.svc.cluster.local:15020
      uri: /healthz/ready
    route:
    - destination:
        host: istio-ingress.gke-system.svc.cluster.local
        port:
          number: 15020
EOF
```

* Modifying the Istio ingress gateway for use with Kubernetes Ingress

### 2-1. Create a JSON Patch file to make changes to the Istio ingress gateway:
```bash
cat <<EOF > istio-ingress-patch.json
[
  {
    "op": "replace",
    "path": "/spec/type",
    "value": "NodePort"
  },
  {
    "op": "remove",
    "path": "/status"
  }
]
EOF
```

### 2-2. Apply the patch file and add the Istio ingress gateway as a backend:
```bash
kubectl -n gke-system patch svc istio-ingress \
    --type=json -p="$(cat istio-ingress-patch.json)" \
    --dry-run=true -o yaml | kubectl apply -f -
kubectl annotate svc istio-ingress -n gke-system cloud.google.com/neg='{"exposed_ports": {"80":{}}}'
```

This patch makes the following changes to the Kubernetes Service object of the Istio ingress gateway:

* Adds the annotation `cloud.google.com/neg: '{"ingress": true}'`. This annotation creates a network endpoint group and enables container-native load balancing when the Kubernetes Ingress object is created.
* Changes the Kubernetes Service type from `LoadBalancer` to `NodePort`. This change removes the Network Load Balancing resources.

### 2-3. Creating a Kubernetes Ingress object

* HTTP
```bash
kubectl apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-ingress
  namespace: gke-system
spec:
  backend:
    serviceName: istio-ingress
    servicePort: 80
EOF
```

* [HTTPS](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb#setting_up_https_tls_between_client_and_load_balancer)
```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-ingress-2
spec:
  tls:
  - secretName: <secret-name>
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: istio-ingress
          servicePort: 60000
```

```bash
kubectl get ingress my-ingress -n gke-system
INGRESS_IP=$(kubectl get ingress my-ingress -n gke-system \
    --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

## 3. Install `KFServing`

```bash
TAG=0.2.2 && \
wget https://raw.githubusercontent.com/kubeflow/kfserving/master/install/$TAG/kfserving.yaml \
    -O "kfserving-${TAG}.yaml"
kubectl apply -f "kfserving-${TAG}.yaml"
```

## 4. Set `inferenceservice`

```bash
curl -fsSL https://raw.githubusercontent.com/kubeflow/kfserving/master/docs/samples/sklearn/sklearn.yaml -O
kubectl apply -f sklearn.yaml
```

## 5. Get a prediction

```bash
curl -fsSL https://raw.githubusercontent.com/kubeflow/kfserving/master/docs/samples/sklearn/iris-input.json -O

MODEL_NAME=sklearn-iris
INPUT_PATH=@./iris-input.json
CLUSTER_IP=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
sleep 20s
SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -o jsonpath='{.status.url}' | cut -d "/" -f 3)
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://$CLUSTER_IP/v1/models/$MODEL_NAME:predict -d $INPUT_PATH
```

Then, the output would be the following:
```ascii
* Expire in 0 ms for 6 (transfer 0x56322055d560)
*   Trying 104.154.142.146...
* TCP_NODELAY set
* Expire in 200 ms for 4 (transfer 0x56322055d560)
* Connected to 104.154.142.146 (104.154.142.146) port 80 (#0)
> POST /v1/models/sklearn-iris:predict HTTP/1.1
> Host: sklearn-iris.default.example.com
> User-Agent: curl/7.64.0
> Accept: */*
> Content-Length: 76
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 76 out of 76 bytes
< HTTP/1.1 200 OK
< content-length: 23
< content-type: text/html; charset=UTF-8
< date: Thu, 07 May 2020 18:19:23 GMT
< server: istio-envoy
< x-envoy-upstream-service-time: 8105
<
* Connection #0 to host 104.154.142.146 left intact
{"predictions": [1, 1]}%
```

Done.

Next Step: **Using `sidecar injection` with `Istio`**

Further Readings about **Sidecar Injection**
1. <https://cloud.google.com/istio/docs/istio-on-gke/installing#enabling_sidecar_injection>
2. https://istio.io/docs/setup/additional-setup/sidecar-injection/

Prerequisite: [`istioctl`](../../istio/README.md#install-istioctl)