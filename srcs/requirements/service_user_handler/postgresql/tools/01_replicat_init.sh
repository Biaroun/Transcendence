#!/bin/sh
set -e

PG_NAME=$POSTGRES_DB
PG_USER=$POSTGRES_USER
PG_PASSWORD=$POSTGRES_PASSWORD

# Wait until data base is ready
until pg_isready -U $PG_USER -d $PG_NAME; do
	echo coucou_1
	sleep 1
done

echo coucou_2
# Wait until tables access is OK
for table in auth_user shared_models_player shared_models_block shared_models_friendship; do
    until PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -t -c "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table';" | grep -q 1; do
        sleep 1
    done
done
echo coucou_3

# Create publications
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -c "
CREATE PUBLICATION auth_user_pub FOR TABLE auth_user;
CREATE PUBLICATION shared_models_pub FOR TABLE shared_models_player, shared_models_block, shared_models_friendship;"
echo coucou_4
