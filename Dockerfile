FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    unixodbc \
    odbc-postgresql \
    libldap-dev \
    && rm -rf /var/lib/apt/lists/*

RUN find /usr/lib -name "libldap-2.5.so*" | head -1 | \
    xargs -I{} ln -s {} /usr/lib/$(uname -m)-linux-gnu/libldap-2.4.so.2 || true

WORKDIR /fdsloader

COPY FDSLoader64 .
COPY cacert.pem .
COPY config .

RUN chmod +x FDSLoader64

RUN mkdir -p /fdsloader/tmp \
    /fdsloader/data \
    /fdsloader/formats \
    /fdsloader/schemas \
    /fdsloader/support \
    /fdsloader/temp \
    /fdsloader/zips

ENV PAR_GLOBAL_TEMP=/fdsloader/tmp

CMD ["./FDSLoader64"]