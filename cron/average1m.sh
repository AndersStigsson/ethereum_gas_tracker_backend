#!/bin/bash
config=$1

# check if config parameter is set
if [[ "$config" == "" ]]
  then
    echo '{"error": "missing config parameter"}'
    exit 1
fi

# check if config file exists
if [[ ! -a $config ]]
  then
    echo '{"error": "missing config file"}'
    exit 1
fi

providers=$(jq -r 'keys[]' $config)

# check if required packages installed (jo,jq,bc)
if [[ "$(which jo)" == "" ]] || [[ "$(which jq)" == "" ]] || [[ "$(which bc)" == "" ]] || [[ "$(which curl)" == "" ]]
  then
    echo '{"error": "missing required packages"}'
    exit 1
fi

# calculate average
timestamp=$(date +%s)
providerfiles=$(sed 's/^\(.*\)/data\/\1.json/g' <<< $providers | tr '\n' ' ' )
levels="slow medium fast instant"
IFS=" "
for level in $levels
    do
        datalist=$(jq -r ".unified.$level" $providerfiles | grep -Ev '^0')
        divider=$(wc -l <<< $datalist)
        declare $level=$(awk '{s+=$1}END{print int(s/'$divider')}' <<< $datalist)
    done

# generate parsed json
average=$(jo -p \
    slow=$slow\
    medium=$medium\
    fast=$fast\
    instant=$instant\
)

# return average data
echo $slow $medium $fast $instant >> data/average1m.log
echo '{"timestamp": '$timestamp'}' '{"average": '$average'}' | jq --slurp 'reduce .[] as $item ({}; . * $item)'