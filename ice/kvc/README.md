# *kvc-via-containers* implementation of install OOT Intel ICE driver

This project is used to build a MachineConfig object, *ice-mc.yaml*, that installs a newer version of the Intel ice driver.  

This project uses the [kmods-via-containers](https://github.com/kmods-via-containers/kmods-via-containers) projects to load kernel modules using containers.  The [kvc-ice-kmod](https://github.com/atyronesmith/kvc-ice-kmod) project is a companion to this project and implements some of the *kmods-via-containers* project requirements.

The *build.sh* script enables the **Cluster-Wide Entitled Builds on OpenShift
** method as outlined in this [blog](https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift)

## Building

To build the *ice-mc.yaml* file,

    ./build.sh build [/path/]entitlement_dir 

The **entitlement_dir** directory contains entitlement
data obtained as outlined in
[this](https://www.openshift.com/blog/how-to-use-entitled-image-builds-to-build-drivercontainers-with-ubi-on-openshift) blog post.

As an example, after attaching a *Red Hat Developer Subscription for Individuals* subscription to a virtual system, download the certificates.  Create an empty directory, **certdir**.  Place the entitlement_certifications/[ID1].pem file in **certdir** and rename to [ID1]-key.pem.  Place the content_access_certificates/[ID2].pem into **certdir**.  Run:

    ./build.sh build certdir

The file *ice-mc.yaml* should be created.  Transfer this file to your cluster and create a new MachineConfig object.

    oc create -f ice-mc.yaml

At this point, the worker nodes will go into a NotReady,SchedulingDisabled state for a while as the MachineConfig object is installed and the nodes are rebooted.

After the workers return to normal, you can check that the new driver is installed:

    [root@silpixa00401060 ~] oc debug nodes/worker1
    Starting pod/worker1-debug ...
    To use host binaries, run `chroot /host`
    Pod IP: 192.168.1.21
    If you don't see a command prompt, try pressing enter.
    sh-4.4# chroot /host
    sh-4.4# cat /sys/bus/pci/drivers/ice/module/version
    1.3.2
