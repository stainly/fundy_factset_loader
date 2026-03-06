#!/bin/bash
set -e

echo "INFO: Setting up DSN..."
sed \
  -e "s|{DATABASE_NAME}|${PGDATABASE}|g" \
  -e "s|{DATABASE_SERVER}|${PGHOST}|g" \
  /fdsloader/DSN-template.ini > /fdsloader/DSN-FDSLoader.ini

odbcinst -i -s -f /fdsloader/DSN-FDSLoader.ini

echo "INFO: Generating config.xml from template..."
sed \
  -e "s|{DATABASE_NAME}|${PGDATABASE}|g" \
  -e "s|{DATABASE_SERVER}|${PGHOST}|g" \
  -e "s|{DATABASE_USER}|${PGUSER}|g" \
  -e "s|{DOWNLOAD_BASEDIR}|/fdsloader/zips|g" \
  -e "s|{FACTSET_SERIAL}|${FACTSET_SERIAL}|g" \
  -e "s|{FACTSET_USER}|${FACTSET_USER}|g" \
  -e "s|{LOCAL_BASEDIR}|/fdsloader|g" \
  -e "s|{MAX_PARALLEL_LIMIT}|${MACHINE_CORES:-4}|g" \
  /fdsloader/config-template.xml > /fdsloader/config.xml

echo "INFO: Encrypting database password..."
./FDSLoader64 --update-password --instance db --pwd "$PGPASSWORD"

echo "INFO: Launching FDSLoader64..."
exec ./FDSLoader64