#!/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

set -e

virsh destroy master0 >> /dev/null 2>&1 &
virsh destroy master1 >> /dev/null 2>&1 &
virsh destroy master2 >> /dev/null 2>&1 &
virsh undefine master0 >> /dev/null 2>&1 &
virsh undefine master1 >> /dev/null 2>&1 &
virsh undefine master2 >> /dev/null 2>&1 &

#rm -rf $QCOWS/master*
#rm $CDROM
