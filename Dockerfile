FROM ubuntu:jammy-20230916

RUN echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main" >> \
      /etc/apt/sources.list \
      && apt-get update && apt-get install --no-install-recommends -y \
      libldap-2.4-2=2.4.* \
      odbc-postgresql=1:13.* \
      postgresql-client=14+* \
      unixodbc=2.3.* \
      && rm -rf /var/lib/apt/lists/*

COPY system/etc/odbcinst.ini /etc/odbcinst.ini

WORKDIR /fdsloader

COPY FDSLoader64 .
COPY cacert.pem .
COPY system/etc/config-template.xml .
COPY system/etc/DSN-template.ini .
COPY entrypoint.sh .

RUN chmod +x FDSLoader64 entrypoint.sh

RUN mkdir -p /fdsloader/tmp \
    /fdsloader/data \
    /fdsloader/formats \
    /fdsloader/schemas \
    /fdsloader/support \
    /fdsloader/temp \
    /fdsloader/zips

ENV PAR_GLOBAL_TEMP=/fdsloader/tmp

CMD ["./entrypoint.sh"]