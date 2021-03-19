#!/bin/bash
# chroot /host/ modprobe $1
kmod_name=$(tr "-" "_" <<< "$1")

if chroot /host/ lsmod | grep "$1" >& /dev/null;
then
  exit 0
else
  chroot /host/ modprobe "$kmod_name"
fi
