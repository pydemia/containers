# Telepresence for Remote Development

## Architecture

* From

```console
  ┌────────────────────────────────────────────────┐
  │              Kubernetes in Cloud               │
  │                                                │
  │ ┌────────────────────────────────────────────┐ │
  │ │     <Your existing app> on port 8000       | │
  │ └────────────────────────────────────────────┘ │
  │                                                │
  └────────────────────────────────────────────────┘
```


* To

```console
  ┌──────────────────────────────────────────────────┐     ┌──────────────────────────────────────────────────────┐
  │               Kubernetes in Cloud                │     │                 Kubernetes in Cloud                  │
  │                                                  │     │                                                      │
  │ ┌──────────────────────────────────────────────┐ │     │ ┌──────────────────────┐    ┌──────────────────────┐ │
  │ │ <Telepresence proxy>, listening on port 8000 |.│.....│.│ Telepresencee client |────│ Telepresencee client | │
  │ └──────────────────────────────────────────────┘ │     │ └──────────────────────┘    └──────────────────────┘ │
  │                                                  │     │                                                      │
  └──────────────────────────────────────────────────┘     └──────────────────────────────────────────────────────┘
```

## Installation

https://www.telepresence.io/docs/latest/install/

### Linux

```bash
# 1. Download the latest binary (~50 MB):
sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence

# 2. Make the binary executable:
sudo chmod a+x /usr/local/bin/telepresence
```

### OSX

* Intel

```bash
# Intel Macs

# Install via brew:
brew install datawire/blackbird/telepresence

# OR install manually:
# 1. Download the latest binary (~60 MB):
sudo curl -fL https://app.getambassador.io/download/tel2/darwin/amd64/latest/telepresence -o /usr/local/bin/telepresence

# 2. Make the binary executable:
sudo chmod a+x /usr/local/bin/telepresence
```

* Apple silicon

```bash
# Apple silicon Macs

# Install via brew:
brew install datawire/blackbird/telepresence-arm64

# OR Install manually:
# 1. Download the latest binary (~60 MB):
sudo curl -fL https://app.getambassador.io/download/tel2/darwin/arm64/latest/telepresence -o /usr/local/bin/telepresence

# 2. Make the binary executable:
sudo chmod a+x /usr/local/bin/telepresence
```

### Windows

[Install Powershell 7 on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?WT.mc_id=THOMASMAURER-blog-thmaure&view=powershell-7)

```powershell
# Windows is in Developer Preview, here is how you can install it:
# Make sure you run the following from Powershell as Administrator
# 1. Download the latest windows zip containing telepresence.exe and its dependencies (~50 MB):
curl -fL https://app.getambassador.io/download/tel2/windows/amd64/latest/telepresence.zip -o telepresence.zip

# 2. Unzip the zip file to a suitable directory + cleanup zip
Expand-Archive -Path telepresence.zip
Remove-Item 'telepresence.zip'
cd telepresence

# 3. Run the install-telepresence.ps1 to install telepresence's dependencies. It will install telepresence to
# C:\telepresence by default, but you can specify a custom path $path with -Path $path
Set-ExecutionPolicy Bypass -Scope Process
.\install-telepresence.ps1

# 4. Remove the unzipped directory
cd ..
Remove-Item telepresence
# 5. Close your current Powershell and open a new one. Telepresence should now be usable as telepresence.exe
```

---

## Usage

### Test `telepresence`

```bash
$ telepresence connect
Launching Telepresence Root Daemon
Launching Telepresence User Daemon
Connected to context <context-name> (https://<cluster public IP>)
```

```bash
$ telepresence status
Root Daemon: Running
  Version   : v2.5.5 (api 3)
  DNS       :
    Remote IP       : 127.0.0.1
    Exclude suffixes: [.arpa .com .io .net .org .ru]
    Include suffixes: []
    Timeout         : 8s
  Also Proxy : (0 subnets)
  Never Proxy: (2 subnets)
    - 3.37.249.56/32
    - 13.209.142.68/32
User Daemon: Running
  Version         : v2.5.5 (api 3)
  Executable      : /usr/local/bin/telepresence
  Install ID      : fe778cf7-6536-4e84-8e3c-877a08c534d1
  Ambassador Cloud:
    Status    : Logged out
    User ID   :
    Account ID:
    Email     :
  Status            : Connected
  Kubernetes server : https://<cluster public IP>
  Kubernetes context: <context-name>
  Intercepts        : 0 total
```

```bash
$ telepresence quit

```

### Intercept a service

* List available

```bash
$ telepresence list
No Workloads (Deployments, StatefulSets, or ReplicaSets)

$ telepresence list -n <namespace>
account   : ready to intercept (traffic-agent not yet installed)
core      : ready to intercept (traffic-agent not yet installed)
history   : ready to intercept (traffic-agent not yet installed)
ifservice : ready to intercept (traffic-agent not yet installed)
monitoring: ready to intercept (traffic-agent not yet installed)
repo      : ready to intercept (traffic-agent not yet installed)
web       : ready to intercept (traffic-agent not yet installed)
```

* Get details

```bash
$ kubectl get service example-service -o yaml
...
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: http
...
```

* Intercept

`telepresence intercept <service-name> --port <local-port>[:<remote-port>] --env-file <path-to-env-file>`
`--env-json=FILENAME`
`telepresence intercept [service] --port [port] -- [COMMAND]`
`--mount=/tmp/`
`--mount=true`: with env `$TELEPRESENCE_ROOT`

> * EnvFile
>   * VSCode: use `envFile` field of your configuration
>   * JetBrains: use the `envFile` plugin

```bash
#  --local-only
$ telepresence intercept example-service \
    --port 8080:http \
    --env-file ./telepresence.env
Using Deployment example-service
intercepted
    Intercept name: example-service
    State         : ACTIVE
    Workload kind : Deployment
    Destination   : 127.0.0.1:8080
    Intercepting  : all TCP connections
```

#### Telepresence Environment Variables

```env
# Directory where all remote volumes mounts are rooted.
#TELEPRESENCE_ROOT

# Colon separated list of remotely mounted directories.
#TELEPRESENCE_MOUNTS

# The name of the intercepted container. Useful when a pod has several containers, and you want to know which one that was intercepted by Telepresence.
#TELEPRESENCE_CONTAINER

# ID of the intercept (same as the "x-intercept-id" http header).
#TELEPRESENCE_INTERCEPT_ID=
```

---

### Launch a proxy to the existing deployment named `core`

```bash
# deployments.apps "core"
NAMESPACE='airuntime'
kubectl -n ${NAMESPACE} get deployments.apps
telepresence \
  --namespace ${NAMESPACE} \
  --new-deployment core \
  --env-json core_env.json

# Available options
  # --serviceaccount \
  # --context \
```

You can debug without modifying the existing deployment, `--new-deployment` option is recommended.

```console
$ telepresence \
    --namespace ${NAMESPACE} \
    --new-deployment core \
    --env-json env.json

NAME   READY   UP-TO-DATE   AVAILABLE   AGE
core   1/1     1            1           3h19m
T: Warning: kubectl 1.20.0 may not work correctly with cluster version 1.17.15-gke.800 due to the version discrepancy. See https://kubernetes.io/docs/setup/version-skew-policy/ for more information.

T: Using a Pod instead of a Deployment for the Telepresence proxy. If you experience problems, please file an issue!
T: Set the environment variable TELEPRESENCE_USE_DEPLOYMENT to any non-empty value to force the old behavior, e.g.,
T:     env TELEPRESENCE_USE_DEPLOYMENT=1 telepresence --run curl hello

T: How Telepresence uses sudo: https://www.telepresence.io/reference/install#dependencies
T: Invoking sudo. Please enter your sudo password.
[sudo] password for ${USER}: 
T: Starting proxy with method 'vpn-tcp', which has the following limitations: All processes are affected, only one telepresence can run per machine, and you can't use other VPNs. You may need to add cloud 
T: hosts and headless services with --also-proxy. For a full list of method limitations see https://telepresence.io/reference/methods.html
T: Volumes are rooted at $TELEPRESENCE_ROOT. See https://telepresence.io/howto/volumes.html for details.
T: Starting network proxy to cluster using new Pod core

T: No traffic is being forwarded from the remote Deployment to your local machine. You can use the --expose option to specify which ports you want to forward.

T: Setup complete. Launching your command.
@gke_ds-ai-platform_us-central1_kfserving-riesling|bash-5.0$ ping systemdb
ping is not supported under Telepresence.
See https://telepresence.io/reference/limitations.html for details.
@gke_ds-ai-platform_us-central1_kfserving-riesling|bash-5.0$ mysql -h ${SYSTEMDB_HOST} -u ${SYSTEMDB_USERNAME} -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 179445
Server version: 10.5.8-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> exit
Bye
@gke_ds-ai-platform_us-central1_kfserving-riesling|bash-5.0$ exit
exit
T: Your process has exited.
T: Exit cleanup in progress
T: Cleaning up Pod
```

In case of `--swap-deployment`:

```console
$ telepresence \
    --namespace ${NAMESPACE} \
    --swap-deployment core \
    --env-json core_env.json

T: Warning: kubectl 1.20.0 may not work correctly with cluster version 1.17.15-gke.800 due to the version discrepancy. See https://kubernetes.io/docs/setup/version-skew-policy/ for more information.

T: Using a Pod instead of a Deployment for the Telepresence proxy. If you experience problems, please file an issue!
T: Set the environment variable TELEPRESENCE_USE_DEPLOYMENT to any non-empty value to force the old behavior, e.g.,
T:     env TELEPRESENCE_USE_DEPLOYMENT=1 telepresence --run curl hello

T: Starting proxy with method 'vpn-tcp', which has the following limitations: All processes are affected, only one telepresence can run per machine, and you can't use other VPNs. You may need to add cloud 
T: hosts and headless services with --also-proxy. For a full list of method limitations see https://telepresence.io/reference/methods.html
T: Volumes are rooted at $TELEPRESENCE_ROOT. See https://telepresence.io/howto/volumes.html for details.
T: Starting network proxy to cluster by swapping out Deployment core with a proxy Pod
T: Forwarding remote port 17005 to local port 17005.

T: Guessing that Services IP range is ['10.8.0.0/20']. Services started after this point will be inaccessible if are outside this range; restart telepresence if you can't access a new Service.
T: Setup complete. Launching your command.
@gke_ds-ai-platform_us-central1_kfserving-riesling|bash-5.0$ exit
exit
T: Your process exited with return code 7.
T: Exit cleanup in progress
T: Cleaning up Pod
```

#### Deployment options

* `--new-deployment`: create a new deployment for the telepresence proxy, preserving the existing deployment, and connect your local machine as a pod. It needs `sudo` privilege.
* `--swap-deployment`: drop the existing deployment and create a new deployment using proxy from local, as a pod. you can launch multiple containers as the pod.
* `--deployment`: re-connect the existing telepresence proxy deployment.

Description:

```ascii
--new-deployment DEPLOYMENT_NAME, -n DEPLOYMENT_NAME
                        Create a new Deployment in Kubernetes where the
                        datawire/telepresence-k8s image will run. It will be
                        deleted on exit. If no deployment option is specified
                        this will be used by default, with a randomly
                        generated name.
  --swap-deployment DEPLOYMENT_NAME[:CONTAINER], -s DEPLOYMENT_NAME[:CONTAINER]
                        Swap out an existing deployment with the Telepresence
                        proxy, swap back on exit. If there are multiple
                        containers in the pod then add the optional container
                        name to indicate which container to use.
  --deployment EXISTING_DEPLOYMENT_NAME, -d EXISTING_DEPLOYMENT_NAME
                        The name of an existing Kubernetes Deployment where
                        the datawire/telepresence-k8s image is already
                        running.
```

---

