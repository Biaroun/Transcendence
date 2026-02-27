#!/bin/sh
set -e

# Secrets extraction from environment variables
PG_NAME=$POSTGRES_DB
PG_USER=$POSTGRES_USER
PG_PASSWORD=$POSTGRES_PASSWORD

sed -i "s/PG_NAME/$PG_NAME/g" /var/lib/postgresql/data/pg_hba.conf
sed -i "s/PG_USER/$PG_USER/g" /var/lib/postgresql/data/pg_hba.conf

# Starts postgres temporarily
pg_ctl -D /var/lib/postgresql/data -o "-c listen_addresses='localhost'" -w start

# Create super user, create replicator, create database, grant privilleges to super user
psql -U postgres -c "CREATE ROLE $PG_USER WITH SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS LOGIN PASSWORD '$PG_PASSWORD';"
psql -U postgres -c "CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '$PG_PASSWORD';"
psql -U postgres -c "CREATE DATABASE $PG_NAME OWNER $PG_USER;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_NAME TO $PG_USER;"

# Wait until data base is ready
until pg_isready -U "$PG_USER" -d "$PG_NAME"; do
	sleep 1
done

# Grant privilleges to replicator
PGPASSWORD=$PG_PASSWORD psql -U "$PG_USER" -d "$PG_NAME" -c "GRANT USAGE ON SCHEMA public TO replicator;"
PGPASSWORD=$PG_PASSWORD psql -U "$PG_USER" -d "$PG_NAME" -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;"
PGPASSWORD=$PG_PASSWORD psql -U "$PG_USER" -d "$PG_NAME" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;"

# Stop postgres temporarily
pg_ctl -D /var/lib/postgresql/data stop
