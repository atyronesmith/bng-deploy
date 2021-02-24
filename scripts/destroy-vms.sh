#!/usr/bin/bash

# shellcheck source=common.sh
source common.sh

set -e

virsh destroy master0 >> /dev/null 2>&1 &
virsh destroy master1 >> /dev/null 2>&1 &
virsh destroy master2 >> /dev/null 2>&1 &
virsh undefine master0 >> /dev/null 2>&1 &
virsh undefine master1 >> /dev/null 2>&1 &
virsh undefine master2 >> /dev/null 2>&1 &

#rm -rf $QCOWS/master*
#rm $CDROM
