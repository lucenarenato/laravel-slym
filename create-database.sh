#!/usr/bin/env bash

mysql --user=root --password="$MYSQL_ROOT_PASSWORD" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS mult;
    GRANT ALL PRIVILEGES ON \`mult%\`.* TO '$MYSQL_USER'@'%';
EOSQL
