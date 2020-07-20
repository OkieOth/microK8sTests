#!/bin/bash
scriptPos=${0%/*}

# helper script to create a connection to the vitual machines

# the script takes as first parameter the IP address for the machine to connect. the
# second parameter is the config base folder to use - single or cluster

# Expected commandline parameters
# $1 - SSH_HOST
# $2 - SSH_USER
# $3 - config to use: single | cluster


if [ -z "$1" ]; then
    while [[ -z ${SSH_HOST} ]] ; do
        read -r -p "Please enter the id address for the ssh connection
> " SSH_HOST
    done
else
    SSH_HOST=$1
fi

if [ -z "$2" ]; then
    while [[ -z ${SSH_USER} ]] ; do
        read -r -p "Please enter the user for the ssh connection
> " SSH_USER
    done
else
    SSH_USER=$2
fi

if ! ping -c 1 $SSH_HOST &> /dev/null; then
    echo "Can't reach the desired host ($SSH_HOST) with ping, cancel"
    exit 1
fi

if [ -z "$3" ]; then
    while ! [[ $configNum -eq 1 || $configNum -eq 2 ]] ; do
        read -r -p "Please choose the setup you want to configure:
  1 - single mircoK8s
  2 - cluster mircorK8s
  > " configNum
    done
    if [[ $configNum -eq 1 ]]; then
        CONFIG_DEST=single
    else
        CONFIG_DEST=cluster
    fi
else
    CONFIG_DEST=$3
fi

configDest="$scriptPos/../vagrant/$CONFIG_DEST"
if ! [ -d "$configDest" ]; then
    echo "Can't find folder for ssh configuration ($configDest), cancel"
    exit 1
fi

echo
echo "Configuration to use:
  IP: $SSH_HOST
  user: $SSH_USER
  for configuration: $CONFIG_DEST"
echo

# checking if there is already an keyfile for the configuration
keyFileName=mircoK8sTest_${CONFIG_DEST}

ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes -i ~/.ssh/$keyFileName $SSH_USER@$SSH_HOST    
