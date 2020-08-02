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

echo "TOKEN:"
echo $TOKEN