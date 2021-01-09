#!/bin/bash

config=$1
providers=$(jq -r 'keys[]' $config)

# check if config file exists
if [[ ! -a $config ]]
  then
    echo '{"error": "missing config file"}'
    exit 1
fi

# check if required packages installed (jo,jq,bc)
if [[ "$(which jo)" == "" ]] || [[ "$(which jq)" == "" ]] || [[ "$(which bc)" == "" ]] || [[ "$(which curl)" == "" ]]
  then
    echo '{"error": "missing required packages"}'
    exit 1
fi

# calculate average
i=1
count=0
slow=0
medium=0
fast=0
instant=0
timestamp=$(date +%s)

for provider in $providers
    do
        data=$(jq '.unified' data/$provider.json)
        if [[ $provider == $(jq -r '.name' <<< $data) ]]
            then
                jTimestamp=$(jq -r '.timestamp' <<< $data)
                timediff=$(($timestamp - $jTimestamp))
                if [[ ! $timediff > 70 ]]
                    then
                        jSlow=$(jq -r '.slow' <<< $data)
                        slow=$(echo "($slow + $jSlow)/$i" | bc -q)
                        jMedium=$(jq -r '.medium' <<< $data)
                        medium=$(echo "($medium + $jMedium)/$i" | bc -q)
                        jFast=$(jq -r '.fast' <<< $data)
                        fast=$(echo "($fast + $jFast)/$i" | bc -q)
                        jInstant=$(jq -r '.instant' <<< $data)
                        if [[ $jInstant > 0 ]]
                            then
                                instant=$(echo "($instant + $jInstant)/$i" | bc -q)
                        fi
                        i=2
                        ((count+=1))
                fi
        fi
    done

# generate parsed json
average=$(jo -p \
    count=$count\
    slow=$slow\
    medium=$medium\
    fast=$fast\
    instant=$instant\
)

# return raw+parsed data
echo '{"timestamp": '$timestamp'}' '{"average": '$average'}' | jq --slurp 'reduce .[] as $item ({}; . * $item)'