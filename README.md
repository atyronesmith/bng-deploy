# Contents

## ice

This directory contains a script to build a MachineConfig object that installs the 1.3.2 version of the Intel Ice driver

## deploy

This directory contains the manifests necessary to deploy the BNG

## dnsmasq

This directory contains the files necessary to deploy the required dnsmasq for DNS

## The following commands were used to setup the physical environment bng-deploy

### Packages

    yum install vim wget git
    yum install epel-release
    yum install ansible
    yum install OpenIPMI ipmitool
    yum groupinstall "Virtualization Platform"
    yum install fuse -y
    yum install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install
    yum groupinstall "X Window System"
    yum install tcpdump dig bind-utils jq
    yum install podman

### Enable virtualization

    virt-host-validate
    vi /etc/default/grub
    grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg

    virsh pool-define-as --name default --type dir --target /home/libvirt
    virsh pool-autostart default

## Firewall rules

    firewall-cmd --zone internal --permanent --change-interface=br-ctrlplane
    firewall-cmd --zone=internal --permanent --add-port=67/udp
    firewall-cmd --zone=internal --permanent --add-port=53/udp
    firewall-cmd --zone=internal --permanent --add-port=67/tcp
    firewall-cmd --zone=internal --permanent --add-port=53/tcp

    firewall-cmd --zone=internal --add-masquerade --permanent
    firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -o p3p2 -j MASQUERADE
    firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i br-ctrlplane -o p3p2 -j ACCEPT
    firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 -i p3p2 -o br-ctrlplane -m state --state RELATED,ESTABLISHED -j ACCEPT
    firewall-cmd --reload

## Additional Cluster config

### Internal Registry

[Configuration Reference](https://computingforgeeks.com/expose-openshift-internal-registry-externally/)

    oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

Check with:

    oc get  route  -n openshift-image-registry

Get Login info:

    HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')

Login with podman:

    podman login -u admin -p $(oc whoami -t) --tls-verify=false $HOST
