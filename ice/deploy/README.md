
# Artifacts related to the build of the ice driver in OpenShift

## Prerequisits

  oc import-image centos:8 --from=centos:8 --confirm

  oc set image-lookup ice-driver
  oc set image-lookup imagestream --list
  