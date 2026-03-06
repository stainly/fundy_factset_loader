FROM ubuntu:jammy-20230916

RUN echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main" >> \
      /etc/apt/sources.list \
      && apt-get update && apt-get install --no-install-recommends -y \
      libldap-2.4-2=2.4.* \
      odbc-postgresql=1:13.* \
      postgresql-client=14+* \
      unixodbc=2.3.* \
      unzip=6.* \
      && rm -rf /var/lib/apt/lists/*

COPY system/etc/odbcinst.ini /etc/odbcinst.ini
COPY system/etc/config-template.xml /usr/local/etc/config-template.xml
COPY system/bin/ /usr/local/bin/

RUN groupadd -r fdsrunner \
      && useradd -r -g fdsrunner fdsrunner \
      && mkdir -p /home/fdsrunner \
      && chown -R fdsrunner /home/fdsrunner

USER fdsrunner
WORKDIR /home/fdsrunner

CMD ["run_data_loader.sh"]