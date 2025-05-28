#!/bin/bash

echo "Waiting for PostgreSQL database at ${HIVE_METASTORE_DB_HOST}:${HIVE_METASTORE_DB_PORT}..."
until PGPASSWORD=${HIVE_METASTORE_DB_PASSWORD} psql -h ${HIVE_METASTORE_DB_HOST} -p ${HIVE_METASTORE_DB_PORT} -U ${HIVE_METASTORE_DB_USER} -d ${HIVE_METASTORE_DB_NAME} -c '\q'; do
  echo "DB not ready, sleeping..."
  sleep 1
done
echo "PostgreSQL database is ready!"

echo "Checking Hive Metastore schema status..."
/opt/hive/bin/schematool -dbType postgres -validate || \
/opt/hive/bin/schematool -dbType postgres -initSchema

echo "Validating Hive Metastore schema after initialization..."
until /opt/hive/bin/schematool -dbType postgres -validate; do
  echo "Schema validation failed, retrying in 5 seconds..."
  sleep 5
done
echo "Hive Metastore schema validated successfully!"

echo "Starting Hive Metastore Server..."
/opt/hive/bin/hive --service metastore "$@"