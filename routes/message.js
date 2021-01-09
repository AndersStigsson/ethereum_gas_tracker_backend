var express = require('express');
var router = express.Router();
//var admin = require("firebase-admin");

//const fetch = require('node-fetch');
/*
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});
var defaultMessaging = admin.messaging();
*/
router.get('/', function(req, res) {
    //ethereum-gas-tracker
    /*var message = {
	  notification: {
	    title: 'Cheap gas fees!',
	    time: 'The gas fees are currently XXX gwei'
	  },
	};

	// Send a message to the device corresponding to the provided
	// registration token.
	admin.messaging().send(message)
	  .then((response) => {
	    // Response is a message ID string.
	    console.log('Successfully sent message:', response);
	  })
	  .catch((error) => {
	    console.log('Error sending message:', error);
	  });*/
    
    res.json({state: "OK"});
});

module.exports = router;