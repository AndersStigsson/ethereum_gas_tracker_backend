#!/bin/bash

providers=$1
provider=$2
apikeylist=config/providers_apikey.json

# check required parameters
if [[ -z $providers ]] || [[ -z $provider ]]
    then
        echo '{"error": "missing required paramters"}'
        exit 1
fi

# check if required packages installed (jo,jq,bc)
if [[ "$(which jo)" == "" ]] || [[ "$(which jq)" == "" ]] || [[ "$(which bc)" == "" ]] || [[ "$(which curl)" == "" ]]
    then
        echo '{"error": "missing required packages"}'
        exit 1
fi

# check if provider exists
if [[ "$(jq -r ". | .$provider? | .name " $providers)" != "$provider" ]]
    then
        jo error="provider does not exists"
        exit 1
fi

# get api information
apiName=$(jq -r ".$provider.name" $providers)
apiURL=$(jq -r ".$provider.url" $providers)
apiKey=$(jq -r ".$provider.apikey" $providers)
apiSlow=$(jq -r ".$provider.slow" $providers)
apiMedium=$(jq -r ".$provider.medium" $providers)
apiFast=$(jq -r ".$provider.fast" $providers)
apiInstant=$(jq -r ".$provider.instant" $providers)
apiDivider=$(jq -r ".$provider.divider" $providers)

# stop if apikey needed
if [[ $apiKey == true ]]
    then
        if [[ ! -a $apikeylist ]]
            then
                jo error="sorry apikey json not found"
                exit 1
        fi
        apiKey=$(jq -r ".$apiName" $apikeylist)
        if [[ -z $apiKey ]]
            then
                jo error="sorry could not find apikey for provider $apiName"
                exit 1
        fi
        apiURL=$(echo $apiURL$apiKey)
fi

# fetch api data
data=$(curl -s $apiURL)
timestamp=$(date +%s)

# parse data
slow=$(echo $( printf '%.0f\n' $(echo $data | jq -r ".$apiSlow"))/$apiDivider | bc -q)
medium=$(echo $( printf '%.0f\n' $(echo $data | jq -r ".$apiMedium"))/$apiDivider | bc -q)
fast=$(echo $( printf '%.0f\n' $(echo $data | jq -r ".$apiFast"))/$apiDivider | bc -q)
instant=$(echo $( printf '%.0f\n' $(echo $data | jq -r ".$apiInstant"))/$apiDivider | bc -q)

# generate parsed json
unified=$(jo -p \
    name=$apiName\
    timestamp=$timestamp\
    slow=$slow\
    medium=$medium\
    fast=$fast\
    instant=$instant\
)

# return raw+parsed data
echo '{"raw": '$data'}' '{"unified": '$unified'}' | jq --slurp 'reduce .[] as $item ({}; . * $item)'