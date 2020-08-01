#!/bin/bash
scriptPos=${0%/*}

if [[ -f $scriptPos/../vagrant/single/ip_address.tmp ]]; then
    hostToConnect=`cat $scriptPos/../vagrant/single/ip_address.tmp`
else
    hostToConnect=singleMicroK8s.local
fi

$scriptPos/connect.sh "$hostToConnect" admin single