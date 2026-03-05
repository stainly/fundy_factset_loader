#!/bin/bash
set -e

echo "Generating config.xml from environment variables..."

cat > /fdsloader/config.xml << XMLEOF
<?xml version='1.0'?>
<data>
    <version>2.13</version>
    <database>
        <cloud>1</cloud>
        <cloud_type>rds</cloud_type>
        <database_name>${DB_NAME:-factset}</database_name>
        <dsn>FDSLoader</dsn>
        <mssql><character_set></character_set></mssql>
        <oracle></oracle>
        <pass>${DB_PASSWORD}</pass>
        <port>${DB_PORT:-5432}</port>
        <server_name>${DB_HOST}</server_name>
        <type>psql</type>
        <user>${DB_USER}</user>
        <using_bulkinsert>0</using_bulkinsert>
    </database>
    <download_only>0</download_only>
    <files>
        <local_basedir>/fdsloader</local_basedir>
        <remote_basedir></remote_basedir>
    </files>
    <first_run>0</first_run>
    <proxy>
        <custom_setting>NONE</custom_setting>
        <password></password>
        <port></port>
        <protocol></protocol>
        <server></server>
        <username></username>
    </proxy>
    <server>
        <auth_type>otp</auth_type>
        <protocol>https</protocol>
        <serial>${FACTSET_SERIAL}</serial>
        <user>${FACTSET_USER}</user>
    </server>
    <advanced>
        <atomic_rebuild>1</atomic_rebuild>
        <max_parallel_limit>16</max_parallel_limit>
    </advanced>
</data>
XMLEOF

echo "config.xml generated."
echo "Launching FDSLoader64..."
exec ./FDSLoader64