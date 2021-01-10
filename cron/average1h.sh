#!/bin/bash

# check if config file exists
if [[ ! -a data/average1m.log ]]
  then
    echo '{"error": "missing average log file"}'
    exit 1
fi

# check if required packages installed (jo,jq,bc)
if [[ "$(which jo)" == "" ]] || [[ "$(which jq)" == "" ]] || [[ "$(which bc)" == "" ]] || [[ "$(which curl)" == "" ]]
  then
    echo '{"error": "missing required packages"}'
    exit 1
fi

# calculate average
slow=0
medium=0
fast=0
instant=0
timestamp=$(date +%s)
data=$(tail -n 60 data/average1m.log)
divider=$(wc -l <<< $data)

slow=$(awk '{s+=$1}END{print int(s/'$divider')}' <<< $data)
medium=$(awk '{s+=$2}END{print int(s/'$divider')}' <<< $data)
fast=$(awk '{s+=$3}END{print int(s/'$divider')}' <<< $data)
instant=$(awk '{s+=$4}END{print int(s/'$divider')}' <<< $data)

# generate parsed json
average=$(jo -p \
    slow=$slow\
    medium=$medium\
    fast=$fast\
    instant=$instant\
)

# return average data
echo $average >> data/average1m.log
echo '{"timestamp": '$timestamp'}' '{"average": '$average'}' | jq --slurp 'reduce .[] as $item ({}; . * $item)'