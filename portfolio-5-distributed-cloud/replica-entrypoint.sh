#!/bin/bash
# Clone the primary with pg_basebackup, then start as a read-only standby.
set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  mkdir -p "$PGDATA"
  chown -R postgres:postgres "$PGDATA"
  chmod 700 "$PGDATA"

  echo "Waiting for primary..."
  until gosu postgres pg_isready -h pg-primary -p 5432 -U postgres; do sleep 2; done
  sleep 3

  echo "Cloning primary with pg_basebackup..."
  gosu postgres env PGPASSWORD=demo_repl_pw \
    pg_basebackup -h pg-primary -U replicator -D "$PGDATA" -R -X stream -P
fi

exec gosu postgres postgres -c hot_standby=on
