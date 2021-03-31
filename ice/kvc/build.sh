#!/bin/bash

set -e

usage() {
    prog=$(basename "$0")
    cat <<-EOM
    Build MachineConfig for ice driver

    Usage:
        $prog command [arguments]
            build /path/entitlements    -- Build cm.yaml
            headers /path/entitlements   -- List available kernel-headers
                
        /path/entitlements -- Directory containing certs/keys to enable privileged kernel deploys.
EOM
}

build() {
    local entitlements="$1"

    if [ ! -d "$entitlements" ]; then
        printf >&2 "Cannot access entitlements directory: %s\n" "$entitlements"
        exit 1
    fi

    printf "Reading certs from: %s\n" "$entitlements"

    FAKEROOT=$(mktemp -d)

    mkdir -p "${FAKEROOT}"/etc/rhsm

    cp ./rhsm.conf "${FAKEROOT}"/etc/rhsm

    mkdir -p "${FAKEROOT}"/etc/pki/entitlement

    for f in "${entitlements}"/*.pem; do
        base=${f##*/}
        cp "$f" "${FAKEROOT}/etc/pki/entitlement/${base}"
    done

    # tar -czf subs.tar.gz /etc/pki/entitlement/ /etc/rhsm/ /etc/yum.repos.d/redhat.repo
    # tar -x -C "${FAKEROOT}" -f subs.tar.gz
    # rm subs.tar.gz

    if [ ! -d kmods-via-containers ]; then
        git clone https://github.com/kmods-via-containers/kmods-via-containers
    fi

    (cd kmods-via-containers && git pull --no-rebase &&
        make install DESTDIR="${FAKEROOT}"/usr/local CONFDIR="${FAKEROOT}"/etc/)

    if [ ! -d kvc-ice-kmod ]; then
        git clone https://github.com/atyronesmith/kvc-ice-kmod.git
    fi

    (cd kvc-ice-kmod && git pull --no-rebase &&
        make install DESTDIR="${FAKEROOT}"/usr/local CONFDIR="${FAKEROOT}"/etc/)

    if [ ! -d filetranspiler ]; then
        git clone https://github.com/ashcrow/filetranspiler
    fi

    (cd filetranspiler && git checkout 1.1.3)

    ./filetranspiler/filetranspile -i ./baseconfig.ign -f "${FAKEROOT}" --format=yaml \
        --dereference-symlinks | sed 's/^/     /' | (cat mc-base.yaml -) >ice-mc.yaml
}

list_kernel_headers() {
    local entitlement="$1"

    podman run --rm -ti --mount type=bind,source="$entitlement",target=/etc/pki/entitlement/entitlement.pem \
        --mount type=bind,source="$entitlement",target=/etc/pki/entitlement/entitlement-key.pem \
        registry.access.redhat.com/ubi8:latest bash -c "dnf search kernel-devel --showduplicates"
}

while getopts ":h" opt; do
    case ${opt} in
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Invalid Option: -$OPTARG" 1>&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

if [ "$#" -gt 0 ]; then
    COMMAND=$1
    shift
else
    COMMAND="build"
fi

case "$COMMAND" in
build)
    if [ "$#" -lt 1 ]; then
        printf >&2 "%s missing 1 arg\n" "$PROGRAM"
        usage
        exit 1
    fi
    build "$1"
    ;;
headers)
    if [ "$#" -lt 1 ]; then
        printf >&2 "%s requires 1 arg\n" "$PROGRAM"
        usage
        exit 1
    fi
    list_kernel_headers "$1"
    ;;
*)
    echo "Unknown command: ${COMMAND}"
    usage
    ;;
esac
