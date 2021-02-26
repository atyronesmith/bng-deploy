#!/usr/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/utils.sh"

VERBOSE="false"
export VERBOSE

usage() {
    cat <<-EOM
    Start/Stop dnsmasq for OCP cluster 

    Usage:
        $(basename "$0") [-h] command 

            start        - Start the $CONTAINER_NAME container 
            stop         - Stop the $CONTAINER_NAME container
            remove       - Stop and remove the $CONTAINER_NAME container
            restart      - Restart $CONTAINER_NAME to reload config files


    Options
EOM
}

while getopts ":hv" opt; do
    case ${opt} in
    v)
        VERBOSE="true"
        ;;
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
    COMMAND="bm"
fi

case "$COMMAND" in
start)
    podman_exists "$CONTAINER_NAME" &&
        (podman_rm "$CONTAINER_NAME" ||
            printf "Could not remove %s!\n" "$CONTAINER_NAME")

    mkdir -p "$SCRIPT_DIR/../dnsmasq/var/run"

    if ! cid=$(sudo podman run -d --name "$CONTAINER_NAME" --net=host \
        -v "$SCRIPT_DIR/../dnsmasq/var/run:/var/run/dnsmasq:Z" \
        -v "$SCRIPT_DIR/../dnsmasq/etc/dnsmasq.d:/etc/dnsmasq.d:Z" \
        --expose=53 --expose=53/udp --expose=67 --expose=67/udp --expose=69 \
        --expose=69/udp --cap-add=NET_ADMIN "$CONTAINER_IMAGE" \
        --conf-file=/etc/dnsmasq.d/dnsmasq.conf -u root -d -q); then
        printf "Could not start %s container!\n" "$CONTAINER_NAME"
        exit 1
    fi

    podman_isrunning_logs "$CONTAINER_NAME" && printf "Started %s as %s...\n" "$CONTAINER_NAME" "$cid"
    ;;
stop)
    podman_stop "$CONTAINER_NAME" && printf "Stopped %s\n" "$CONTAINER_NAME" || exit 1
    ;;
restart)
    podman_restart "$CONTAINER_NAME" && printf "Restarted %s\n" "$CONTAINER_NAME" || exit 1
    ;;
remove)
    status=$(podman_rm "$CONTAINER_NAME") && printf "%s %s\n" "$CONTAINER_NAME" "$status" || exit 1
    ;;
isrunning)
    if ! podman_isrunning "$CONTAINER_NAME"; then
        printf "%s is NOT running...\n" "$CONTAINER_NAME"
        exit 1
    else
        printf "%s is running...\n" "$CONTAINER_NAME"
    fi
    ;;
*)
    echo "Unknown command: ${COMMAND}"
    usage
    ;;
esac
