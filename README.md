# ethereum_gas_tracker_backend
## setup
apt -y install nodejs npm jo jq curl bc bash
git clone $repo
cd /ethereum_gas_tracker_backend
mkdir data
npm install
crontab -l > /tmp/crontab
echo "* * * * * $(pwd)/cron/cron.sh" >> /tmp/crontab
crontab /tmp/crontab
rm /tmp/crontab
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/firebase-key.json"
npm start

## apikeys
add apikeys to $(pwd)/config/provides_apikey.json
```json
{
    "providerX": "API-123-KEY-456",
    "providerY": "API-123-KEY-789",
    "providerY": "API-456-KEY-789"
}
```