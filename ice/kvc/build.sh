#!/bin/bash

FAKEROOT=$(mktemp -d)

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
