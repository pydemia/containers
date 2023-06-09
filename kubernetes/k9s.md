# Install `kubectl` and `k9s`

```bash
# kubectl
K8S_CLUSTER_VERSION="1.26"
curl -LO "https://dl.k8s.io/release/v${K8S_CLUSTER_VERSION}.0/bin/linux/amd64/kubectl"

# k9s

## < 0.24.x
k9s_version="v0.24.2"
k_os_type="linux"  # "darwin" for mac
curl -L https://github.com/derailed/k9s/releases/download/"${k9s_version}"/k9s_"$(echo "${k_os_type}" |sed 's/./\u&/')"_x86_64.tar.gz -o k9s.tar.gz && \
  mkdir -p ./k9s && \
  tar -zxf k9s.tar.gz -C ./k9s && \
  sudo mv ./k9s/k9s /usr/local/bin/ && \
  rm -rf ./k9s ./k9s.tar.gz && \
  echo "\nInstalled in: $(which k9s)"

## < 0.26.x
k9s_version="v0.27.2"
k_os_type="Linux"  # "Darwin" for mac
curl -L https://github.com/derailed/k9s/releases/download/"${k9s_version}"/k9s_"$(echo "${k_os_type}" |sed 's/./\u&/')"_amd64.tar.gz -o k9s.tar.gz && \
  mkdir -p ./k9s && \
  tar -zxf k9s.tar.gz -C ./k9s && \
  mv ./k9s/k9s ~/.local/bin/ && \
  rm -rf ./k9s ./k9s.tar.gz && \
  echo "\nInstalled in: $(which k9s)"
```
