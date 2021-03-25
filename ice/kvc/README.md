# kvc-via-containers implementation of install OOT Intel ICE driver

This project is used to build a MachineConfig object, *mc.yaml*, that can be
applied to an OpenShift cluster.  The MachineConfig object enables the install
of an OOT version of the Intel ICE driver.

## Building

To build the *mc.yaml* object,

```bash
./build.sh [/path/]entitlement.pem
```

The entitlement.pem file specifies a file that contains a certification and entitlement
data obtained as outlined in 
[this](https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift) blog post.
