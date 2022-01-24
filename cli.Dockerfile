FROM registry.access.redhat.com/ubi8 as decompressor
WORKDIR /install
COPY *.tgz .
RUN tar -xvf ./ASE_Suite.linuxamd64.tgz

FROM registry.access.redhat.com/ubi8
WORKDIR /install
COPY --from=decompressor /install/ebf29704 .
RUN mkdir /opt/sap
RUN yum update -y && \
  yum install -y libaio gtk2 glibc libnsl2 procps
COPY *.txt .

# This is really not a good idea, but this is required as libnsl 1.x is no longer available on RHEL8
RUN ln -s /usr/lib64/libnsl.so.2 /usr/lib64/libnsl.so.1

RUN ./setup.bin -f ./ase-cli.txt -r /opt/sap/sybase-install-options.txt \
  -DAGREE_TO_SAP_LICENSE=true \
  -i silent \
  -DRUN_SILENT=true

ENV PATH="/opt/sap/OCS-16_0/bin:/opt/sap/ASE-16_0/bin:/opt/sap/ASE-16_0/install:/opt/sap/WLA/bin:${PATH}" \
  LANG=en_US \
  SYBASE=/opt/sap
EXPOSE 5000

RUN rm -rf /install \
  && rm -rf /opt/sap/log/* \
  && yum clean all

WORKDIR /