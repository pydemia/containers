# `containerd`

See: https://github.com/containerd/containerd

```bash
curl -fsSLO https://github.com/containerd/containerd/releases/download/v1.7.2/containerd-1.7.2-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.2-linux-amd64.tar.gz

curl -fsSLO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
#sudo mv containerd.service /usr/local/lib/systemd/system/containerd.service
sudo mv containerd.service /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```


## 2. `runc`

```bash
curl -fsSLO https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

## 3. Installing CNI plugins
```bash
sudo mkdir -p /opt/cni/bin
curl -fsSLO https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
```


```bash
which ctr
```
