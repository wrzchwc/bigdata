#!/bin/bash

set -e 

until pg_isready -h hive-metastore-db; do echo 'Waiting for DB...'; sleep 2; done

if ! schematool -dbType postgres -info | grep -q 'version'; then
    echo 'Initializing Hive schema...';
    schematool -dbType postgres -initSchema;
else
    echo 'Hive schema already initialized.';
fi
hive --service metastore