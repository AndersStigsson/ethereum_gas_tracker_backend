var express = require('express');
var router = express.Router();
const fs = require('fs');
const fetch = require('node-fetch');


var admin = require("firebase-admin");
admin.initializeApp({
    credential: admin.credential.applicationDefault(),
});
var defaultMessaging = admin.messaging();
//const fetch = require('node-fetch');


/* GET home page. */
router.get('/', function(req, res) {
    res.send("Backend works");
});

// list of providers
router.get('/providers', function(req, res) {
    const data = fs.readFileSync('./config/providers.json', {encoding:'utf8', flag:'r'});
    const providerList = JSON.parse(data);
    res.json({providers: Object.keys(providerList)});
});

// average of all providers from current data
router.get('/gas/avg', function(req,res){
    const data = fs.readFileSync('./data/average.json', {encoding:'utf8', flag:'r'});
    const average = JSON.parse(data);
    res.json(average);
});

// average of all providers latest crontab, fetched every minute
router.get('/gas/avg/1m', function(req, res){
    const data = fs.readFileSync('./data/average1m.json', {encoding:'utf8', flag:'r'});
    const average = JSON.parse(data);
    res.json(average);
});

// average of last 60 minutes (60 snapshots, one for each minute)
router.get('/gas/avg/1h', function(req, res){
    const data = fs.readFileSync('./data/average1h.json', {encoding:'utf8', flag:'r'});
    const average = JSON.parse(data);
    res.json(average);
});

// current data from provider
router.get('/gas/:provider', function(req, res) {
    const provider = req.params.provider;
    const providers = fs.readFileSync('./config/providers.json', {encoding:'utf8', flag:'r'});
    var providerJSON = JSON.parse(providers); 

    if(providerJSON[provider] === undefined) {
        res.json({error: "The provider you look for does not exist or has not been implemented yet"});
    } else {
        var data = fs.readFileSync(`./data/${provider}.json`, {encoding:'utf8', flag:'r'});
        data = JSON.parse(data);
        res.json(data);
    }
});

router.get('/message/send', function(req, res) {
    var gasPrice = req.query.price;
    //ethereum-gas-tracker
    console.log(req.query);
    var message = {
        notification: {
            title: 'Cheap gas fees!',
            body: `The gas fees are currently ${gasPrice} gwei`
        },
        topic: "ethereum_gas"
    };
    console.log(message);
    // Send a message to the device corresponding to the provided
    // registration token.
    defaultMessaging.send(message)
        .then((response) => {
            // Response is a message ID string.
           console.log('Successfully sent message:', response);
        })
        .catch((error) => {
            console.log('Error sending message:', error);
        });
    res.json({state: "OK"});
});

module.exports = router;