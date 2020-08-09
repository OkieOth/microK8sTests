#!/bin/bash
scriptPos=${0%/*}

# helper script to connect kubectl to a single instance microk8s installation

if [[ -f $scriptPos/../vagrant/single/ip_address.tmp ]]; then
    hostToConnect=`cat $scriptPos/../vagrant/single/ip_address.tmp`
else
    hostToConnect=singleMicroK8s.local
fi



SSH_HOST=$hostToConnect 
SSH_USER=admin
CONFIG_DEST=single

echo
echo "Configuration to use:
  IP: $SSH_HOST
  user: $SSH_USER
  for configuration: $CONFIG_DEST"
echo

# checking if there is already an keyfile for the configuration
keyFileName=mircoK8sTest_${CONFIG_DEST}

TOKEN=`ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes -i ~/.ssh/$keyFileName $SSH_USER@$SSH_HOST \
    /snap/bin/microk8s kubectl config view | grep token | awk '{ print $2}'`

if [[ -z "$TOKEN" ]]; then
    echo "can't get token for the connection"
    exit 1
fi

echo "TOKEN to access the dashboard:"
echo "$TOKEN"

kubectl --kubeconfig=$scriptPos/../kubectlConfig/single-microk8s --user=admin \
    --token="$TOKEN" \
    --server=https://`ping -c 1 singleMicroK8s.local | grep PING | awk '{print $3}' | sed -e 's-(--' -e 's-)--'`:16443 \
    proxy --address="0.0.0.0" --port=9091
