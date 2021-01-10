#!/bin/bash
cd /ethereum_gas_tracker_backend
config=config/providers.json
getgas=./cron/getgas.sh
providers=$(jq -r 'keys[]' $config)

for provider in $providers
    do
        $getgas $config $provider > data/$provider.json &
    done

# wait 5 seconds for all providers to respond
sleep 5
./cron/average1m.sh $config > data/average1m.json &
./cron/average1h.sh > data/average1h.json

# clean up log
echo $(tail -n 180 data/average1m.log) > data/average1m.log