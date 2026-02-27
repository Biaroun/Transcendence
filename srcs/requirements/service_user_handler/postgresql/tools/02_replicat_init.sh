#!/bin/sh
set -e

PG_NAME=$POSTGRES_DB
PG_USER=$POSTGRES_USER
PG_PASSWORD=$POSTGRES_PASSWORD

PG_NAME_GAME_PONG=$GAME_PONG_POSTGRES_DB
PG_USER_GAME_PONG=$GAME_PONG_POSTGRES_USER
PG_PASSWORD_GAME_PONG=$GAME_PONG_POSTGRES_PASSWORD

# Wait until data base is ready
until pg_isready -U $PG_USER -d $PG_NAME; do
	sleep 1
done

# Wait until service_game_pong_postgresql data base is ready
until pg_isready -h service_game_pong_postgresql -U $PG_USER_GAME_PONG -d $PG_NAME_GAME_PONG; do
	sleep 1
done

# Wait until table access is OK
until PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -t -c "SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'shared_models_tournament';" | grep -q 1; do
	sleep 1
done

# Wait until publication access on service_game_pong_postgresql is OK
until PGPASSWORD=$PG_PASSWORD_GAME_PONG psql -h service_game_pong_postgresql -U $PG_USER_GAME_PONG -d $PG_NAME_GAME_PONG -t -c "SELECT 1 FROM pg_publication WHERE pubname = 'tournament_match_pub';" | grep -q 1; do
    sleep 1
done

# Create subscription and connect to service_game_pong_postgresql publication
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_NAME -c "
CREATE SUBSCRIPTION user_sub_tournament_data
CONNECTION 'host=service_game_pong_postgresql dbname=$PG_NAME_GAME_PONG user=replicator password=$PG_PASSWORD_GAME_PONG'
PUBLICATION tournament_match_pub;"
