FROM centos:8 AS builder

ARG BUILD_KERNEL

RUN dnf makecache \  
#  && dnf group install "Development Tools" -y \
  && dnf install -y wget \
  && wget "http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/kernel-headers-$BUILD_KERNEL.rpm" \
  && yum -y localinstall "kernel-headers-$BUILD_KERNEL.rpm" \
  && wget "http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/kernel-devel-$BUILD_KERNEL.rpm" \
  && yum -y localinstall "kernel-devel-$BUILD_KERNEL.rpm" \
  && dnf install gcc make rpm-build -y \
  && dnf install -y elfutils-libelf-devel module-init-tools 

FROM builder AS compiler

ARG builddir=/root/ice
ARG driver_version=1.3.2
ARG BUILD_KERNEL

RUN mkdir -p $builddir && cd $builddir && wget "https://sourceforge.net/projects/e1000/files/ice%20stable/$driver_version/ice-$driver_version.tar.gz" \
  && rpmbuild --define "_topdir $builddir" -tb ice-$driver_version.tar.gz 

FROM centos:8 AS runtime

LABEL io.k8s.display-name="ice driver $driver_version" \
  io.k8s.description="Container to install version $driver_version of the Intel ice driver"

ARG builddir=/root/ice
ARG driver_version=1.3.2
ARG BUILD_KERNEL

RUN mkdir -p $builddir

COPY --from=compiler $builddir/RPMS/x86_64/ice-$driver_version-1.x86_64.rpm $builddir

RUN dnf makecache \
  && dnf install -y wget \
  && wget "http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/kernel-headers-$BUILD_KERNEL.rpm" \
  && yum localinstall -y "kernel-headers-$BUILD_KERNEL.rpm" \
  && wget "http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/kernel-core-$BUILD_KERNEL.rpm" \
  && yum localinstall -y "kernel-core-$BUILD_KERNEL.rpm" \
  && dnf install -y $builddir/ice-$driver_version-1.x86_64.rpm \
  && dnf clean all

ADD load-kmod.sh /usr/local/bin
RUN chmod +x /usr/local/bin/load-kmod.sh
