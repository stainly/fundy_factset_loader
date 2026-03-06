#!/bin/bash
set -e

echo "=== DEBUG: Environment diagnostics ==="
echo "INFO: Checking shared library dependencies..."
ldd /fdsloader/FDSLoader64 | grep "not found" && echo "WARNING: Missing libraries detected!" || echo "INFO: All libraries found."
echo "INFO: libcrypt status:"
ls -la /usr/lib/$(uname -m)-linux-gnu/libcrypt* 2>/dev/null || echo "WARNING: No libcrypt found!"
echo "INFO: PAR_GLOBAL_TEMP=$PAR_GLOBAL_TEMP"
ls -la "$PAR_GLOBAL_TEMP" 2>/dev/null || echo "WARNING: PAR_GLOBAL_TEMP dir missing!"
echo "INFO: Working directory: $(pwd)"
echo "INFO: Files in /fdsloader:"
ls -la /fdsloader/
echo "INFO: config-template.xml line count: $(wc -l < /fdsloader/config-template.xml)"
echo "=== END DEBUG ==="

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
  -e "s|{FACTSET_SERIAL}|${FACTSET_SERIAL}|g" \
  -e "s|{FACTSET_USER}|${FACTSET_USER}|g" \
  -e "s|{LOCAL_BASEDIR}|/fdsloader|g" \
  -e "s|{MAX_PARALLEL_LIMIT}|${MACHINE_CORES:-4}|g" \
  /fdsloader/config-template.xml > /fdsloader/config.xml

echo "INFO: Generated config.xml ($(wc -l < /fdsloader/config.xml) lines):"
cat /fdsloader/config.xml

echo "=== DIAGNOSTIC: Testing FDSLoader64 commands ==="

echo "--- TEST 1: --help ---"
./FDSLoader64 --help 2>&1 || echo "EXIT CODE: $?"

echo "--- TEST 2: --version ---"
./FDSLoader64 --version 2>&1 || echo "EXIT CODE: $?"

echo "--- TEST 3: PAR extracted contents ---"
ls -laR /fdsloader/tmp/

echo "--- TEST 4: Checking extracted .so dependencies ---"
find /fdsloader/tmp -name "*.so*" -exec ldd {} \; 2>&1 | grep "not found" || echo "All extracted .so dependencies found."

echo "--- TEST 5: strace on --help ---"
strace -f -e trace=open,openat,execve ./FDSLoader64 --help 2>&1 | tail -80

echo "=== DIAGNOSTIC COMPLETE ==="
echo "Container will sleep to allow kubectl exec if needed."
sleep 3600