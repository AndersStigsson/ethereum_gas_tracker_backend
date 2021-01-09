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
router.get('/providers', function(req, res) {
    const data = fs.readFileSync('./providers.json', {encoding:'utf8', flag:'r'});
    const providers = JSON.parse(data);
    res.json(providers);
});

router.get('/', function(req, res) {
    res.text("Backend works");
});

router.get('/gas/avg', function(req,res){
	
});

router.get('/gas/avg/1m', function(req, res){
    const data = fs.readFileSync('./average1m.json', {encoding:'utf8', flag:'r'});
    const average = JSON.parse(data);
    res.json(average);
});

router.get('/gas/avg/1h', function(req, res){
    const data = fs.readFileSync('./average1h.json', {encoding:'utf8', flag:'r'});
    const average = JSON.parse(data);
    res.json(average);
});

router.get('/gas:provider', function(req, res) {
    const provider = req.params.provider;
    const data = fs.readFileSync('./providerInfo.json', {encoding:'utf8', flag:'r'});
    const url = JSON.parse(data.provider);
    //make fetch call to url to get real time value from provider.
    res.json(providers);
});

router.get('/gas/all', function(req,res) {

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