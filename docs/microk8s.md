## start the kubectl proxy to access the dashboard
This can be ran on the master node but it opens the dashboard from the 
master node to the public net. If you do so it seems you can't use the
common token authentication for e.g. an external host.

**Attention**, it seems much smoother to start the proxy on your access
machine. An example is in `../bin/proxy_singleDashboard.sh`. In this case
kubectl acts in the same way as ssh and tunnels node port to localhost.

```bash
microk8s.kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
```


## To enable the skip of the login in the dashbord do the following steps
**Attention**, avoid this on production!

Source: `https://github.com/ubuntu/microk8s/issues/292`
```bash
# start editing the configuration
microk8s.kubectl edit deployment/kubernetes-dashboard --namespace=kube-system
# no restart of Kubernetes is needed
```
and add enable-skip-login as below:

```bash
spec:
      containers:
      - args:
        - --auto-generate-certificates
        - --enable-skip-login
        image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
"/tmp/kubectl-edit-snu9z.yaml" 102L, 4077C 
```

## Token Authentication
```bash
# show all secrets for the kube-system namespace
microk8s.kubectl -n kube-system get secret
# display the value of the default token
microk8s.kubectl -n kube-system describe secret default-token-{xxxxx}


# file that contains system known tokens
# Attention, this file can be placed in a different folder
# it seems the token works only if you not access over the kubectl proxy
cat /snap/microk8s/1503/known_token.csv
```

## Access cluster from another machine

1. Install kubectl `snap install kubectl --classic`
2. Check the kubectl configuration `kubectl cluster-info`
3. Check the kubectl configuration `kubectl config view`
4. Auto completion for zsh: add the following line to ~/.zshrc `source <(kubectl completion zsh)`
5. Export the current cluster configuration from inside you cluster
     `microk8s.kubectl config view > single-microk8s`
6. Copy the exported configuration to your host
7. Exec kubectl from your host `kubectl --kubeconfig=single-microk8s cluster-info`
8. You can overwrite some parameters from the config file with command line switches.

```bash
# more sophisticated example - that replaces the VM machine name with the IP address
kubectl --kubeconfig=single-microk8s --user=admin --token=emhrNUQ1ZFV6MFk4WHY3UkVWQmw3WUxyL1dKVUJYTnBUZUpOVGd2YTc4RT0K --server=https://`ping -c 1 singleMicroK8s.local | grep PING | awk '{print $3}' | sed -e 's-(--' -e 's-)--'`:16443 cluster-info

```

## Proxy dashboard from another machine
An example is implemented in `../bin/proxy_singleDashboard.sh`.

```bash
## retrieve the access token and print it. It is implizit called in 
## proxy_singleDashboard.sh
#./bin/print_singleToken.sh

## use kubectl to proxy the dashboard to local and open it in your default 
## browser. The script uses port 9090 per defaut
./bin/proxy_singleDashboard.sh


```

