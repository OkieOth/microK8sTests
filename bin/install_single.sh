#!/bin/bash
scriptPos=${0%/*}

# helper script to install a single microK8s instance in a virtual machine

# the script takes as first parameter the IP address for the machine to connect. the
# second parameter is the config base folder to use - single or cluster

# Expected commandline parameters
# $1 - SSH_HOST
# $2 - SSH_USER
# $3 - SUDO password for the VM


if [[ -z "$1" ]]; then
    if [[ -f $scriptPos/../vagrant/single/ip_address.tmp ]]; then
        hostToConnect=`cat $scriptPos/../vagrant/single/ip_address.tmp`
    else
        hostToConnect=singleMicroK8s.local
    fi
    if ping -c 1 "$hostToConnect"; then
        SSH_HOST=$hostToConnect
    else
        hostToConnect=''
        while [[ -z ${SSH_HOST} ]] ; do
            read -r -p "Please enter the id address for the ssh connection
> " SSH_HOST
        done
    fi
else
    SSH_HOST=$1
fi

if [ -z "$2" ]; then
    if ! [[ -z "$hostToConnect" ]]; then
        SSH_USER=admin
    else
        while [[ -z ${SSH_USER} ]] ; do
            read -r -p "Please enter the user for the ssh connection
> " SSH_USER
        done
    fi
else
    SSH_USER=$2
fi

export SSH_USER

if ! ping -c 1 $SSH_HOST &> /dev/null; then
    echo "Can't reach the desired host ($SSH_HOST) with ping, cancel"
    exit 1
fi

CONFIG_DEST=single

configDest="$scriptPos/../vagrant/$CONFIG_DEST"

if ! [ -d "$configDest" ]; then
    echo "Can't find folder for ssh configuration ($configDest), cancel"
    exit 1
fi

if ! [[ -z "$3" ]]; then
    SSH_PASSWORD=$3
else
    if ! [[ -z "$hostToConnect" ]]; then
        SSH_PASSWORD=demo123
    else
        while [[ -z ${SSH_PASSWORD} ]] ; do
            read -r -s -p "Please enter the user password for the ssh connection
> " SSH_PASSWORD
        done
    fi
fi


echo
echo "Configuration to use:
  IP: $SSH_HOST
  user: $SSH_USER
  for configuration: $CONFIG_DEST"
echo

# check the ssh configuration and if not ready is will be configured
if ! $scriptPos/configure_ssh.sh "$SSH_HOST" "$SSH_USER" "$CONFIG_DEST" "$SSH_PASSWORD"; then
    echo "error while configuring ssh connection"
    exit 1
fi

export ANSIBLE_NOCOWS=1 
export ANSIBLE_PIPELINING=True
export ANSIBLE_REMOTE_USER=$SSH_USER

# checking if there is already an keyfile for the configuration
keyFileName=mircoK8sTest_${CONFIG_DEST}

ansible-playbook \
--verbose \
--inventory="$SSH_HOST", \
--timeout 30 \
--extra-vars="ansible_become_pass=$SSH_PASSWORD" \
--private-key="~/.ssh/$keyFileName" \
$scriptPos/../ansible/install_single.yml