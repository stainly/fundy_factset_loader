#!/bin/bash
set -euo pipefail

# ── Persist key.txt on exit (success or crash) ───────────────────────
cleanup() {
  cp /fdsloader/key.txt /fdsloader/keydir/key.txt 2>/dev/null || true
}
trap cleanup EXIT

# ── LD_LIBRARY_PATH for ODBC driver resolution ──────────────────────
if [ -f /etc/profile.d/odbc.sh ]; then
  # shellcheck disable=SC1091
  source /etc/profile.d/odbc.sh
fi

# ── Sync key.txt from persistent volume ──────────────────────────────
if [ -f /fdsloader/keydir/key.txt ]; then
  cp /fdsloader/keydir/key.txt /fdsloader/key.txt
  chmod 600 /fdsloader/key.txt
  echo "INFO: key.txt loaded from persistent volume."
fi

# ── Setup DSN ────────────────────────────────────────────────────────
echo "INFO: Setting up DSN..."
sed \
  -e "s|{DATABASE_SERVER}|${PGHOST}|g" \
  -e "s|{DATABASE_NAME}|${PGDATABASE}|g" \
  /fdsloader/DSN-template.ini > /fdsloader/DSN-FDSLoader.ini

odbcinst -i -s -f /fdsloader/DSN-FDSLoader.ini
echo "INFO: DSN installed."

# ── Generate config.xml ──────────────────────────────────────────────
echo "INFO: Generating config.xml from template..."
sed \
  -e "s|{DATABASE_NAME}|${PGDATABASE}|g" \
  -e "s|{DATABASE_SERVER}|${PGHOST}|g" \
  -e "s|{DATABASE_USER}|${PGUSER}|g" \
  -e "s|{FACTSET_SERIAL}|${FACTSET_SERIAL}|g" \
  -e "s|{FACTSET_USER}|${FACTSET_USER}|g" \
  -e "s|{LOCAL_BASEDIR}|/fdsloader|g" \
  -e "s|{MAX_PARALLEL_LIMIT}|${MACHINE_CORES:-4}|g" \
  /fdsloader/config-template.xml > /fdsloader/config.xml

echo "INFO: config.xml generated."

# ── Encrypt DB password ──────────────────────────────────────────────
echo "INFO: Encrypting database password..."
./FDSLoader64 --update-password --instance db --pwd "${PGPASSWORD}"

# ── Run loader ───────────────────────────────────────────────────────
echo "INFO: Running FDSLoader64..."
./FDSLoader64 2>&1 | tee /fdsloader/run_results.txt
loader_exit=$?

# ── Handle errors ────────────────────────────────────────────────────
run_errors=$(grep -c "ERROR" /fdsloader/run_results.txt || true)
if [ "$run_errors" -gt 0 ] || [ "$loader_exit" -ne 0 ]; then
  echo "ERROR: FDSLoader completed with errors."
  echo "INFO: Generating support file..."
  ./FDSLoader64 --support --support-logs-max 5
  cp support_*.zip /fdsloader/keydir/ 2>/dev/null || true
  exit 1
fi

echo "INFO: FDSLoader completed successfully."