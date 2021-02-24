#!/usr/bin/bash

export MEMORY=16384
export VCPUS=8
export IMAGE_SIZE=100
export MASTER0_MAC=00:16:3e:78:ab:00
export MASTER1_MAC=00:16:3e:78:ab:01
export MASTER2_MAC=00:16:3e:78:ab:02

#export LIBVIRT_MASTER_POOL="ocs_images" # Storage pool used for VM disk backends
#export CDROM=/var/lib/libvirt/boot/discovery-image-3569876b-e265-454f-86eb-2c8f57abc99d.iso
export CDROM=/root/discovery_image_bng.iso
#export BRIDGE=br-ctlplane
export BRIDGE=ocp-ctlplane
