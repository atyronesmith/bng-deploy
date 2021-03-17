#!/bin/bash

set -euo pipefail
# Pull the latest version of the image, in order to
# populate the build cache:
podman pull quay.io/aasmith/ice:build-stage || true
podman pull quay.io/aasmith/ice:compile-stage    || true
podman pull quay.io/aasmith/ice:latest        || true

# Build the image with tools stage:
podman build --target builder \
       --cache-from=quay.io/aasmith/ice:build-stage \
       --tag quay.io/aasmith/ice:build-stage .

# Build the ice driver, using cached builder state.
podman build --target compiler \
       --cache-from=quay.io/aasmith/ice:build-stage \
       --cache-from=quay.io/aasmith/ice:compile-stage \
       --tag quay.io/aasmith/ice:compile-stage .

# Build the runtime image
# 
podman build --target runtime \
       --cache-from=quay.io/aasmith/ice:compile-stage \
       --cache-from=quay.io/aasmith/ice:latest \
       --tag quay.io/aasmith/ice:latest .

podman push quay.io/aasmith/ice:build-stage
podman push quay.io/aasmith/ice:compile-stage
podman push quay.io/aasmith/ice:latest