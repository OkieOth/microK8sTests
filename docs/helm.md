# General
Helm is used in this setup to install the needed services

# Requirements
* Installed kubectl
* Installed k8 cluster
* Installed helm client `https://github.com/helm/helm/releases`

The following information are mostly collected here:
`https://helm.sh/docs/intro/quickstart/`

# Usage
## Install
To install helm under Linux download the suitable release, extract the tar ball, place
it inside the search path, that's it.

## Init a Repository
```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# search for all stable charts in the helm repository
helm search repo stable

# search for keycloak charts
helm search repo keycloak
```

## Configure helm connection to Kubernetes
```bash
# in case your kubernetes api server isn't public available
# step 1 - proxy the k8 api server to localhost 9091
./bin/proxy_apiserver.sh

# step 2 - run helm and connect to proxied api-server
keyFileName=mircoK8sTest_single; \
SSH_USER=admin; \
SSH_HOST=singleMicroK8s.local; \
TOKEN=`ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes -i ~/.ssh/$keyFileName $SSH_USER@$SSH_HOST \
    /snap/bin/microk8s kubectl config view | grep token | awk '{ print $2}'`; \
echo "config: SSH_USER=$SSH_USER, SSH_HOST=$SSH_HOST, TOKEN=***" && \
helm ls \
    --kube-apiserver=localhost:9091 \
    --kubeconfig=./kubectlConfig/single-microk8s \
    --kube-token="$TOKEN"
```
