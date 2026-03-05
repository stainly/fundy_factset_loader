FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    unixodbc \
    odbc-postgresql \
    libldap-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap-2.5.so.0 /usr/lib/x86_64-linux-gnu/libldap-2.4.so.2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /fdsloader

COPY FDSLoader64 .
COPY cacert.pem .

RUN chmod +x FDSLoader64

ENV PAR_GLOBAL_TEMP=/fdsloader/tmp
RUN mkdir -p /fdsloader/tmp

CMD ["./FDSLoader64"]