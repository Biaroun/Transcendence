#!/bin/sh
set -e

# Secrets extraction from environment variables
PG_NAME=$POSTGRES_DB
PG_USER=$POSTGRES_USER
PG_PASSWORD=$POSTGRES_PASSWORD

PG_NAME_USER_HANDLER=$USER_HANDLER_POSTGRES_DB
PG_USER_USER_HANDLER=$USER_HANDLER_POSTGRES_USER
PG_PASSWORD_USER_HANDLER=$USER_HANDLER_POSTGRES_PASSWORD

# Wait until data base is ready
until pg_isready -U $PG_USER -d $PG_NAME; do
	sleep 1
done

# Wait until service_user_handler_postgresql data base is ready
until pg_isready -h service_user_handler_postgresql -U $PG_USER_USER_HANDLER -d $PG_NAME_USER_HANDLER; do
	sleep 1
done

# Wait until tables access is OK
for table in shared_models_tournament shared_models_match; do
	until PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -t -c "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table';" | grep -q 1; do
		sleep 1
	done
done

# Wait until tables access is OK
for table in auth_user shared_models_player shared_models_block shared_models_friendship; do
	until PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -t -c "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = '$table';" | grep -q 1; do
		sleep 1
	done
done

# Wait until auth_user_pub publication access on service_user_handler_postgresql is OK
until PGPASSWORD=$PG_PASSWORD_USER_HANDLER psql -h service_user_handler_postgresql -U $PG_USER_USER_HANDLER -d $PG_NAME_USER_HANDLER -t -c "SELECT 1 FROM pg_publication WHERE pubname = 'auth_user_pub';" | grep -q 1; do
	sleep 1
done

# Wait until auth_user_pub publication access on service_user_handler_postgresql is OK
# Wait until shared_models_pub publication access on service_user_handler_postgresql is OK
until PGPASSWORD=$PG_PASSWORD_USER_HANDLER psql -h service_user_handler_postgresql -U $PG_USER_USER_HANDLER -d $PG_NAME_USER_HANDLER -t -c "SELECT 1 FROM pg_publication WHERE pubname = 'shared_models_pub';" | grep -q 1; do
	sleep 1
done

# Create publications
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -c "
CREATE PUBLICATION tournament_match_pub FOR TABLE shared_models_tournament, shared_models_match;"

# Create subscription and connect to service_user_handler_postgresql publications
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -c "
CREATE SUBSCRIPTION game_sub_auth_user
CONNECTION 'host=service_user_handler_postgresql dbname=$PG_NAME_USER_HANDLER user=replicator password=$PG_PASSWORD_USER_HANDLER'
PUBLICATION auth_user_pub;"

PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -c "
CREATE SUBSCRIPTION game_sub_player_data
CONNECTION 'host=service_user_handler_postgresql dbname=$PG_NAME_USER_HANDLER user=replicator password=$PG_PASSWORD_USER_HANDLER'
PUBLICATION shared_models_pub;"
