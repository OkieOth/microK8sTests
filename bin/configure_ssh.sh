#!/bin/bash
scriptPos=${0%/*}

# helper script to configure the by Ansible needed key authentication

# the script takes as first parameter the IP address for the machine to connect. the
# second parameter is the config base folder to use - single or cluster

# Expected commandline parameters
# $1 - SSH_HOST
# $2 - SSH_USER
# $3 - config to use: single | cluster
# $4 - SSH_PASSWORD


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
keyFilePath=${configDest}/ssh/${keyFileName}

if ! [[ -f $keyFilePath ]]; then
    echo 'create SSH key: $keyFilePath'
    ssh-keygen -f "$keyFilePath" -C "mircoK8sTest: ${SSH_USER}@${SSH_HOST}" -N ""
else
    echo "SSH key file already exists: $keyFilePath"
fi

# checking if the key is already copied to $HOME/.ssh, if not, then it is copied
if ! [[ -f $HOME/.ssh/${keyFileName} ]]; then
    echo 'copy SSH key to $HOME/.ssh'
    cp ${keyFilePath} $HOME/.ssh
else
    echo 'SSH key file is already in $HOME/.ssh'
fi

echo "try to connect with the keyfile on machine $SSH_HOST ..."
if ! ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes -i ~/.ssh/$keyFileName $SSH_USER@$SSH_HOST date > /dev/null; then    
    if ! [[ -z "$4" ]]; then
        SSH_PASSWORD=$4
    fi
    while [[ -z ${SSH_PASSWORD} ]] ; do
        read -r -s -p "Please enter the user password for the ssh connection
> " SSH_PASSWORD
    done
    echo "    try to copy keyfile to machine ..."
    if ! sshpass -p "$SSH_PASSWORD" ssh-copy-id -i "${keyFilePath}" -o StrictHostKeyChecking=no -o PreferredAuthentications=password -o PubkeyAuthentication=no $SSH_USER@$SSH_HOST; then
        echo "ERROR while copy ssh keys to $SSH_HOST, cancel"
        exit 1
    else 
        echo "    ... key file successfully copied"
        if ! ssh -o PasswordAuthentication=no -o PubkeyAuthentication=yes -i ~/.ssh/$keyFileName $SSH_USER@$SSH_HOST date > /dev/null; then    
            echo "ERROR while test connection with copied key, cancel"
            exit 1
        else
            echo "... test login successfully"
        fi
    fi
else
    echo "... successful logged in"
fi
