FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    unixodbc \
    odbc-postgresql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /fdsloader

COPY FDSLoader64 .
COPY cacert.pem .

RUN chmod +x FDSLoader64

ENV PAR_GLOBAL_TEMP=/fdsloader/tmp
RUN mkdir -p /fdsloader/tmp

CMD ["./FDSLoader64"]
