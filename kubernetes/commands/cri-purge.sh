
wget https://raw.githubusercontent.com/reefland/cri-purge/master/cri-purge.sh
chmod 750 cri-purge.sh
sudo mv cri-purge.sh /usr/local/bin/cri-purge

sudo cri-purge --list
sudo cri-purge --purge

# just in case of `Error while dialing dial unix /var/run/dockershim.sock: connect: no such file or directory"`:
# WARN[0000] image connect using default endpoints: [unix:///var/run/dockershim.sock unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead.
# ERRO[0000] validate service connection: validate CRI v1 image API for endpoint "unix:///var/run/dockershim.sock": rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing dial unix /var/run/dockershim.sock: connect: no such file or directory"
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock --set image-endpoint=unix:///run/containerd/containerd.sock
