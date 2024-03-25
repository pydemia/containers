alias k='kubectl '

source <(kubectl completion bash)


function b64e() {
  echo `echo ${1}|base64`
}


function b64d() {
  echo `echo ${1}|base64 -d`
}

function delete_po () {
  NAMESPACE="${2:-default}"
  POD_NAME="$1"
  kubectl -n $NAMESPACE delete po $POD_NAME --force --grace-period=0
}

function kns () {
  kubectl config set-context --current --namespace="$1"
}

# "kubectl -n istio-system get gw ingress-prd -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' | yq -y"
function kx () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CMD="${3:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath="{.items[0].metadata.name}")" -- ${CMD}
}

function kxc () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CONTAINER="$3"
  CMD="${4:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath='{.items[0].metadata.name}')" -c ${CONTAINER} -- ${CMD}
}

function kxp () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  PODNAME="$2"
  CONTAINER="$3"
  CMD="${4:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty ${PODNAME} -c ${CONTAINER} -- ${CMD}
}

function kdb () {
  NAMESPACE="${1:-default}"
  SA="${2:-default}"
  kubectl -n ${NAMESPACE} run --rm -it debug --image=pydemia/debug --restart=Never #--serviceaccount=${SA}
}

function kdbs () {
  NAMESPACE="${1:-default}"
  SA="${2:-default}"
  kubectl -n ${NAMESPACE} run --rm -it debug --image=pydemia/debug-slim --restart=Never #--serviceaccount=${SA}
}

#alias delete_jobs='kubectl -n corus delete po `kubectl -n corus get po -o custom-columns=:.metadata.name|grep restart-apps` &&  kubectl -n corus get po -o custom-columns=:.metadata.name|grep restart-apps | awk '{print $1}' | xargs kubectl -n corus delete po --force --grace-period=0'
#alias cleanup-rs='kubectl get replicaset -o jsonpath='{ .items[?(@.spec.replicas==0)]}' -A | k delete -f - '

# ==========================================
# Install `cri-purge`:
#wget https://raw.githubusercontent.com/reefland/cri-purge/master/cri-purge.sh
#chmod 750 cri-purge.sh
# sudo mv cri-purge.sh /usr/local/bin/cri-purge

# just in case of `Error while dialing dial unix /var/run/dockershim.sock: connect: no such file or directory"`:
# WARN[0000] image connect using default endpoints: [unix:///var/run/dockershim.sock unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead.
# ERRO[0000] validate service connection: validate CRI v1 image API for endpoint "unix:///var/run/dockershim.sock": rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial unix /var/run/dockershim.sock: connect: no such file or directory"
#sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock

#sudo cri-purge --list
#sudo cri-purge --purge
# ==========================================

function pull_on_node () {
  IMAGE="${1}"
  ctr --namespace=k8s.io images pull ${IMAGE}
}

