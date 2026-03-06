FROM ubuntu:jammy-20230916

# Add focal-updates for libldap-2.4-2 (FDSLoader64 PAR runtime links against 2.4, not 2.5)
RUN echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main" >> /etc/apt/sources.list \
    && apt-get update && apt-get install --no-install-recommends -y \
      libexpat1=2.4.* \
      libldap-2.4-2=2.4.* \
      libnss3=2:3.68.* \
      odbc-postgresql=1:13.* \
      postgresql-client=14+* \
      unixodbc=2.3.* \
      unzip=6.* \
    && rm -rf /var/lib/apt/lists/*

# Register ODBC drivers system-wide
COPY system/etc/odbcinst.ini /etc/odbcinst.ini

# Persist LD_LIBRARY_PATH for ODBC .so resolution in non-interactive shells
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "export LD_LIBRARY_PATH=$(dpkg-query -L odbc-postgresql | grep psqlodbcw.so | xargs dirname):${LD_LIBRARY_PATH:-}" \
      >> /etc/profile.d/odbc.sh \
    && chmod +x /etc/profile.d/odbc.sh

# Non-root user (matches reference repo)
RUN groupadd -r fdsrunner \
    && useradd -r -g fdsrunner -m fdsrunner

WORKDIR /fdsloader

COPY system/etc/config-template.xml ./
COPY system/etc/DSN-template.ini ./
COPY entrypoint.sh ./

# FDSLoader64 and cacert.pem are fetched by CI from the assets repo
COPY FDSLoader64 ./
COPY cacert.pem ./

RUN chmod +x FDSLoader64 entrypoint.sh \
    && mkdir -p tmp data formats schemas support temp zips \
    && chown -R fdsrunner:fdsrunner /fdsloader

ENV PAR_GLOBAL_TEMP=/fdsloader/tmp

USER fdsrunner

CMD ["./entrypoint.sh"]