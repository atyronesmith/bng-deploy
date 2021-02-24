#!/usr/bin/bash

# shellcheck source=common.sh
source common.sh

# Create Master1 VM
virt-install \
  --autostart \
  --virt-type=kvm \
  --name master0 \
  --memory "$MEMORY" \
  --vcpus="$VCPUS" \
  --os-variant=rhel8.1 \
  --cdrom="$CDROM" \
  --network=bridge:"$BRIDGE",mac="$MASTER0_MAC" \
  --disk path=/home/libvirt/images/master0.qcow2,size="$IMAGE_SIZE",bus=virtio,format=qcow2 \
  --events on_reboot=restart \
  --wait=-1 \
  --noautoconsole \
  --quiet


# Create Master1 VM
virt-install \
  --autostart \
  --virt-type=kvm \
  --name master1 \
  --memory "$MEMORY" \
  --vcpus="$VCPUS" \
  --os-variant=rhel8.1 \
  --cdrom="$CDROM" \
  --network=bridge:"$BRIDGE",mac="$MASTER1_MAC" \
  --disk path=/home/libvirt/images/master1.qcow2,size="$IMAGE_SIZE",bus=virtio,format=qcow2 \
  --events on_reboot=restart \
  --wait=-1 \
  --noautoconsole \
  --quiet

# Create Master2 VM
virt-install \
  --autostart \
  --virt-type=kvm \
  --name master2 \
  --memory "$MEMORY" \
  --vcpus="$VCPUS" \
  --os-variant=rhel8.1 \
  --cdrom="$CDROM" \
  --network=bridge:"$BRIDGE",mac="$MASTER2_MAC" \
  --disk path=/home/libvirt/images/master2.qcow2,size="$IMAGE_SIZE",bus=virtio,format=qcow2 \
  --events on_reboot=restart \
  --wait=-1 \
  --noautoconsole \
  --quiet
