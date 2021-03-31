# Deploy Directory

## app-agf-cp-policy.yaml

SriovNetworkNodePolicy to activate the *Application AGF Control Plane* interface(s).

## app-agf-up-policy.yaml

SriovNetworkNodePolicy to activate the *Application AGF User Plane* interface(s).

## infra-dcf-policy.yaml

SriovNetworkNodePolicy to activate the *Infrastructure DCF* interface(s).

## infra-dcf-sriovnetwork.yaml

SriovNetwork manifest to create the infra-dcf network in the cluster

## bng-namespace.yaml

Kubernetes Namespace where the BNG project resides.

## performance-profile.yaml

PerformanceProfile manifest to

* Allocate CPU resources
* Allocate Hugepage resources
* Tune kernel parameters
