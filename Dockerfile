FROM ubuntu:22.04

RUN apt-get update && apt-get install --no-install-recommends -y \
      libldap-2.5-0 \
      odbc-postgresql \
      postgresql-client \
      unixodbc \
      && rm -rf /var/lib/apt/lists/*

RUN find /usr/lib -name "libldap-2.5.so*" | head -1 | \
    xargs -I{} ln -s {} /usr/lib/$(uname -m)-linux-gnu/libldap-2.4.so.2 || true

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