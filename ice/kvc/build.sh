#!/bin/bash

usage() {
    prog=$(basename "$0")
    cat <<-EOM
    Build MachineConfig for ice driver

    Usage:
        $prog [/path/]entitlement.pem
            entitlement.pem -- File containing certs/keys to enable privileged kernel deploys.
EOM
}

if [ "$#" -lt 1 ]; then
    printf >&2 "\tMissing argument\n"
    usage
    exit 1
fi

entitlement=$1

if [ ! -e "$entitlement" ]; then
  printf >&2 "Cannot access entitlement file: %s\n" "$entitlement"
  exit 1
fi

FAKEROOT=$(mktemp -d)

cp "$entitlement" "${FAKEROOT}"/etc/pki/entitlement/entitlement.pem || exit
cp "$entitlement" "${FAKEROOT}"/etc/pki/entitlement/entitlement-key.pem || exit

if [ ! -d kmods-via-containers ]; then
    git clone https://github.com/kmods-via-containers/kmods-via-containers || exit
fi

(cd kmods-via-containers && git pull --no-rebase &&
    make install DESTDIR="${FAKEROOT}"/usr/local CONFDIR="${FAKEROOT}"/etc/) || exit

if [ ! -d kvc-ice-kmod ]; then
    git clone https://github.com/atyronesmith/kvc-ice-kmod.git || exit
fi

(cd kvc-ice-kmod && git pull --no-rebase &&
    make install DESTDIR="${FAKEROOT}"/usr/local CONFDIR="${FAKEROOT}"/etc/) || exit

if [ ! -d filetranspiler ]; then
    git clone https://github.com/ashcrow/filetranspiler || exit
fi

(cd filetranspiler && git checkout 1.1.3) || exit

./filetranspiler/filetranspile -i ./baseconfig.ign -f "${FAKEROOT}" --format=yaml \
    --dereference-symlinks | sed 's/^/     /' | (cat mc-base.yaml -) >mc.yaml
