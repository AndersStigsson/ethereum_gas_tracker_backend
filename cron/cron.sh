#!/bin/bash

cd /ethereum_gas_tracker_backend
config=config/providers.json
getgas=./cron/getgas.sh
providers=$(jq -r 'keys[]' $config)

for provider in $providers
  do
    $getgas $config $provider > data/$provider.json &
  done