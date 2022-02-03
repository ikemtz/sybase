FROM registry.access.redhat.com/ubi8 as decompressor
WORKDIR /install
COPY *.tgz .
RUN tar -xvf ./ASE_Suite.linuxamd64.tgz

FROM registry1.dso.mil/ironbank/redhat/ubi/ubi8:8.5-fips
WORKDIR /install
COPY --from=decompressor /install/ebf29704 .
RUN mkdir /opt/sap
RUN yum update -y && \
  yum install -y libaio gtk2 glibc libnsl2 procps
COPY *.txt .

# This is really not a good idea, but this is required as libnsl 1.x is no longer available on RHEL8
RUN ln -s /usr/lib64/libnsl.so.2 /usr/lib64/libnsl.so.1

RUN ./setup.bin -f ./ase-minimal.txt -r /opt/sap/sybase-install-options.txt \
  -DAGREE_TO_SAP_LICENSE=true \
  -i silent \
  -DRUN_SILENT=true

ENV PATH="/opt/sap/OCS-16_0/bin:/opt/sap/ASE-16_0/bin:/opt/sap/ASE-16_0/install:/opt/sap/WLA/bin:${PATH}" \
  LANG=en_US \
  SYBASE=/opt/sap
EXPOSE 5000

WORKDIR /

RUN rm -rf /install \
  && rm -rf /opt/sap/log/* \
  && yum clean all \
  && sed -i 's/enable console logging = DEFAULT/enable console logging = 1/g' /opt/sap/ASE-16_0/LMSYBASE.cfg \
  && sed -i 's/enable encrypted columns = DEFAULT/enable encrypted columns = 1/g' /opt/sap/ASE-16_0/LMSYBASE.cfg \
  && sed -i 's/FIPS login password encryption = DEFAULT/FIPS login password encryption = 1/g' /opt/sap/ASE-16_0/LMSYBASE.cfg \
  && sed -i 's/automatic master key access = DEFAULT/automatic master key access = 1/g' /opt/sap/ASE-16_0/LMSYBASE.cfg \
  && sed -i 's/master tcp ether localhost 5000/master tcp ether 0.0.0.0 5000/g' /opt/sap/interfaces \
  && sed -i 's/query tcp ether localhost 5000/query tcp ether 127.0.0.1 5000/g' /opt/sap/interfaces \
  && chmod -R g+rwX /opt/sap \
  && rm -rf /opt/sap/ASE-16_0/install/LMSYBASE.log \
  && rm -rf /opt/sap/LMSYBASE_BS.cfg.0* \
  && rm -rf /opt/sap/interf.old \
  && rm -rf /opt/sap/ASE-16_0/LMSYBASE.0* \
  && rm -rf /opt/sap/ASE-16_0/LMSYBASE.b*

COPY entrypoint.sh /
COPY init.sh /

RUN chmod +x /entrypoint.sh && \
    chmod +x /init.sh

USER 1001
CMD ["/init.sh"]
ENTRYPOINT ["/entrypoint.sh"]