
# Enable an out-of-tree Intel Ice driver

This directory contains manifests to deploy and OOT Intel Ice driver.  

The method used here employs a BuildConfig object to create an image that
contains the specified Ice kernel module.  The kernel module is compiled
from [source](https://sourceforge.net/projects/e1000/files/ice%20stable/).

The method outlined here is a short-term method for introducing an OOT driver and should not take the place of the [Special Resource Operator](https://github.com/openshift/special-resource-operator).  The following method requires an update to the *BuildConfig* if a new version of the OOT driver is required or the cluster is upgraded.

## BuildConfig Details

The output of the BuildConfig is an image that is placed in the local cluster registry.  An ImageStream is used as a proxy for the image.

```yaml
output:
    to:
      kind: ImageStreamTag
      name: "ice-kmod-driver-container:latest"
```

The Docker strategy is used and a pull secret `default-dockercfg-9hdp6` is used to enable pulling the driver-toolkit base image from `openshift-dev-release`.  The *pullSecret* field references a *Secret* that was created with the contents of a `.dockerconfig` file that had access to the repo.

```yaml
 strategy:
    type: Docker
    dockerStrategy:
      pullSecret:
        name: default-dockercfg-9hdp6
      buildArgs:
        - name: KMODVER
          value: 1.3.2
```

The driver-toolkit image was determine as follows...

```bash
OCP_VERSION=$(oc get clusterversion/version -ojsonpath={.status.desired.version})
DRIVER_TOOLKIT_IMAGE=$(oc adm release info $OCP_VERSION --image-for=driver-toolkit)
```

**DRIVER_TOOLKIT_IMAGE** was used to populate the **FROM** statement in the *dockerfile*

`FROM $DRIVER_TOOLKIT_IMAGE`

`FROM quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:...`

Privileged builds are enabled with

```yaml
    secrets:
      - secret:
          name: entitlement
```

Where the *Secret* `entitlement` was obtained from `cloud.redhat.com`...

## Enabling the OOT driver

The driver is loaded on worker nodes using a *Daemonset* and *kmods-via-containers*.  The driver-toolkit base image includes an install of the [kmods-via-containers](https://github.com/openshift-psap/kmods-via-containers) framework.  The BuildConfig *git* source is an implementation of a [KVC](https://github.com/atyronesmith/kvc-ice-kmod.git) framework specifc to the OOT driver (*ice-kmod*).  The Dockerfile includes an enablement of the *systemd* service for kmods-via-containers, i.e.

`RUN systemctl enable kmods-via-containers@ice-kmod`

When *kmods-via-containers* is running in *Kubernetes* as opposed to directly on the host (i.e. with MachineConfig), the *kmods-via-containers* driver and container building are skipped and only the kernel module load operation is performed.  Each node where the *Daemonset* pod is run, will have the OOT driver loaded.

