#!/bin/bash

set -o pipefail

pg() {
    sudo -u postgres psql --no-psqlrc "$@"
}

has_failure=0

while read -r dbname; do
    if [[ $dbname = 'postgres' || $dbname = 'template0' || $dbname = 'template1' ]]; then
        continue
    fi

    echo "Backing up $dbname"

    if ! resticx backup --stdin --stdin-filename "postgres-db:$dbname" --stdin-from-command -- \
             sudo -u postgres pg_dump --format=custom --compress=0 "--dbname=$dbname"
    then
        has_failure=1
        echo "Backup failed for $dbname"
    fi
done < <(pg -c 'COPY (SELECT datname FROM pg_database) TO STDOUT WITH CSV;')

exit $has_failure
