#!/bin/bash

cd /ethereum_gas_tracker_backend
config=config/providers.json
getgas=./cron/getgas.sh
getgasavg=./cron/average1m.sh
providers=$(jq -r 'keys[]' $config)

for provider in $providers
  do
    $getgas $config $provider > data/$provider.json &
  done

# wait 5 seconds for all providers to respond
sleep 5
$getgasavg $config > data/average1m.json &