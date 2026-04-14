#!/bin/bash

shopt -s nullglob

export RESTIC_CACHE_DIR=/root/.cache/restic/

has_failure=0

echo "Running setup scripts"

for setup in /etc/restic-backup/setup/*; do
    echo "Running: $setup"

    if ! "$setup"; then
        has_failure=1
        echo "Setup script $setup failed" >&2
    fi
done

echo "Done running setup scripts"

echo "Running restic"

cat /etc/restic-backup/files/* >/etc/restic-backup/files-materialized
cat /etc/restic-backup/excludes/* >/etc/restic-backup/excludes-materialized

resticx backup \
    --files-from /etc/restic-backup/files-materialized \
    --exclude-file /etc/restic-backup/excludes-materialized \
    || exit 1

{% if restic_forget_keep %}

if ! resticx forget --prune \
   {% for keep, value in restic_forget_keep.items() %} --keep-{{ keep }} "{{ value }}"{% endfor %}

then
    has_failure=1
    echo "restic forget --prune failure!" >&2
fi

if ! resticx check; then
    has_failure=1
    echo "restic check failure!" >&2
fi

{% endif %}

echo "Running teardown scripts"

for teardown in /etc/restic-backup/teardown/*; do
    echo "Running: $teardown"

    if ! "$teardown"; then
        has_failure=1
        echo "Teardown script $teardown failed" >&2
    fi
done

echo "Done running teardown scripts"

if [[ $has_failure = 1 ]]; then
    echo "There were errors while performing the backup" >&2
fi

exit $has_failure
