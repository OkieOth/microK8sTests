# mircoK8sTests
Some Vagrant setups to play around with mircoK8s

To install provision the used virtual machines is ansible used

# Requirements
* installed VirtualBox or HyperV
* installed vagrant
* installed Ansible

Tested under Ubuntu 20.04

# Usage
```bash
# configuration of ssh key usage to login into the virtual machines
./bin/configure_ssh.sh
```

# Folder Project Structure
* ansible - Ansible scripts to prepare the virtual machines
* bin - contains helper scripts to simplify usage
* vagrant - base for the vagrant machines
* vagrant/single - single machine Kubernetes
* vagrant/cluster - a Kubernetes cluster that constists of one master and three worker nodes
