#!/usr/bin/bash

# shellcheck disable=SC1091
source "common.sh"
source "utils.sh"

VERBOSE="false"
export VERBOSE

while getopts ":ho:v" opt; do
    case ${opt} in
    o)
        out_dir=$OPTARG
        ;;
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

    if ! cid=$(sudo podman run -d --name "$CONTAINER_NAME" --net=host \
        -v "$PROJECT_DIR/dnsmasq.d:/etc/dnsmasq.d:Z" \
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
