#!/usr/bin/env bash
set -euo pipefail

awslocal sns create-topic --name sqlserver_cdc-dbo-pessoa