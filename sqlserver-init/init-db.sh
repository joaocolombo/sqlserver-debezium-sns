#!/bin/bash
set -e

SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
SERVER="sqlserver"
DBUSER="sa"
DBPASS="YourStrong!Passw0rd"

echo ">> Aguardando SQL Server ficar disponivel..."
for i in $(seq 1 30); do
  if $SQLCMD -S "$SERVER" -U "$DBUSER" -P "$DBPASS" -C -Q "SELECT 1" >/dev/null 2>&1; then
    echo ">> SQL Server disponivel!"
    break
  fi
  echo "   tentativa $i/30 - aguardando..."
  sleep 3
done

echo ">> Executando script de criacao do banco e habilitacao do CDC..."
$SQLCMD -S "$SERVER" -U "$DBUSER" -P "$DBPASS" -C -i /scripts/create-cdc.sql

echo ">> Concluido com sucesso."
