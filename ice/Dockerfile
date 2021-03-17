FROM registry.access.redhat.com/ubi8 AS builder

RUN dnf group install -y "Development Tools"
RUN dnf install -y "kernel-devel-uname-r == $(uname -r)"
RUN dnf install -y wget elfutils-libelf-devel module-init-tools

# Install more packages.
# RUN yum install -y sudo pciutils vim wget \
#     gcc automake autoconf libtool make net-tools \
#     expect

FROM quay.io/aasmith/ice:build-stage AS compiler

RUN wget 'https://sourceforge.net/projects/e1000/files/ice%20stable/1.3.2/ice-1.3.2.tar.gz'
  
# # Install prerequisite packages
# RUN yum groupinstall -y "Development Tools" && \
#     yum install --skip-broken -y wget numactl numactl-devel make libibverbs-devel logrotate rdma-core tcpdump && \
#     yum clean all

RUN tar xvf ice-1.3.2.tar.gz

RUN cd ice-1.3.2/src && \
    make install 
# FROM quay.io/aasmith/testpmd:compile-stage AS dpdk-image

# ENV DPDK_VER 19.11
# ENV DPDK_DIR /usr/src/dpdk-${DPDK_VER}
# ENV RTE_TARGET=x86_64-native-linuxapp-gcc
# ENV RTE_SDK=${DPDK_DIR}

# # Install prerequisite packages
# RUN yum install --skip-broken -y wget numactl numactl-devel make libibverbs-devel logrotate rdma-core tcpdump && \
#     yum clean all

# # Download the DPDK libraries
# RUN wget http://fast.dpdk.org/rel/dpdk-${DPDK_VER}.tar.xz -P /usr/src && \
#     tar -xpvf /usr/src/dpdk-${DPDK_VER}.tar.xz -C /usr/src && \
#     rm -f /usr/src/dpdk-${DPDK_VER}.tar.xz

# # Configuration
# RUN sed -i -e 's/EAL_IGB_UIO=y/EAL_IGB_UIO=n/' \
#       -e 's/KNI_KMOD=y/KNI_KMOD=n/' \
#       -e 's/LIBRTE_KNI=y/LIBRTE_KNI=n/' \
#       -e 's/LIBRTE_PMD_KNI=y/LIBRTE_PMD_KNI=n/' $DPDK_DIR/config/common_linux && \
#     sed -i 's/\(CONFIG_RTE_LIBRTE_MLX5_PMD=\)n/\1y/g' $DPDK_DIR/config/common_base

# # Build it
# RUN cd ${DPDK_DIR} && \
#     make install T=${RTE_TARGET} DESTDIR=${RTE_SDK} -j 8


FROM registry.access.redhat.com/ubi8 AS runtime

# # # macaddr DPDK application
# # COPY macaddr ${DPDK_DIR}/examples/macaddr/

# # RUN cd ${DPDK_DIR}/examples/macaddr && \
# #     make && \
# #     cp ${DPDK_DIR}/examples/macaddr/build/app/macaddr /usr/local/bin

# # # python required for expand-cpu util
# RUN yum install -y python3 && yum clean all

# # Install prerequisite packages
# RUN yum install --skip-broken -y wget numactl numactl-devel make libibverbs-devel logrotate rdma-core tcpdump && \
#     yum clean all

# # DEBUGGING: htop added for toobox debugging
# RUN dnf install -y epel-release
# RUN dnf install -y htop lsof perf && dnf clean all

# COPY --from=dpdk-image /usr/src/dpdk-19.11/x86_64-native-linuxapp-gcc/app/testpmd /usr/local/bin

# # COPY testpmd-as-load-balancer/v19.11/test-pmd ${DPDK_DIR}/app/test-pmd
# # RUN cd ${DPDK_DIR}/app/test-pmd && \
# #     make -j 8 && \
# #     cp testpmd /usr/local/bin

# # # copy testpmd runtime cmdline file
# # COPY testpmd-runtime-cmds.txt /root/testpmd-runtime-cmds.txt
# # COPY scripts /usr/local/bin
