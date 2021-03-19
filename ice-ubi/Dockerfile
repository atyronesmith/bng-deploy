FROM registry.access.redhat.com/ubi8 AS builder

COPY *.pem /etc/pki/entitlement/entitlement.pem
COPY *.pem /etc/pki/entitlement/entitlement-key.pem

RUN dnf makecache \  
  && dnf group install "Development Tools" -y \
  && dnf install -y --disableplugin=subscription-manager "kernel-devel-$(uname -r)" \
  && dnf install -y --disableplugin=subscription-manager gcc autoconf automake make \
  && dnf install -y --disableplugin=subscription-manager wget elfutils-libelf-devel module-init-tools

# Install more packages.
# RUN yum install -y sudo pciutils vim wget \
#     gcc automake autoconf libtool make net-tools \
#     expect

FROM builder AS compiler

ARG builddir=/root/ice
ARG driver_version=1.3.2

RUN mkdir -p $builddir && cd $builddir && wget "https://sourceforge.net/projects/e1000/files/ice%20stable/$driver_version/ice-$driver_version.tar.gz" \
    && rpmbuild --define "_topdir $builddir" -tb ice-$driver_version.tar.gz 
  
FROM registry.access.redhat.com/ubi8 AS runtime

LABEL io.k8s.display-name="ice driver $driver_version" \
      io.k8s.description="Container to install version $driver_version of the Intel ice driver"
 
ARG builddir=/root/ice
ARG driver_version=1.3.2

RUN mkdir -p $builddir

COPY --from=compiler $builddir/RPMS/x86_64/ice-$driver_version-1.x86_64.rpm $builddir

RUN dnf makecache \
    && dnf install -y "kernel-devel-$(uname -r)" \
    && dnf install -y "kernel-$(uname -r)" \
    && dnf install -y $builddir/ice-$driver_version-1.x86_64.rpm \
    && dnf clean all

ADD load-kmod.sh /usr/local/bin
