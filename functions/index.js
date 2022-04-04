
const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp(functions.config().firebase);

var notificationDoc;

exports.chatNotification = functions.firestore.document(
    'messages/{messageId}'
).onCreate(async (snapshot, context) => {
    chatDoc = snapshot.data();

    admin.firestore().collection('users').get()
        .then((snapshots) => {
           
            var contentDoc = snapshot.data();
            var tokens = [];
            if (snapshots.empty) {
                for (var token of snapshots.docs) {
                    tokens.push(token.data().pushToken);
                }
                var payload = {
                    notification: {
                        title: 'new Messages',
                        body: 'you have a new message',
                    },
                    data: {
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                        sendername: "Flash",
                        message: 'you have a new order',
                        title: 'New Order',



                    }
                };
                return console.log('No Devices');
            }
            else {
                for (var token of snapshots.docs) {
                    tokens.push(token.data().pushToken);
                }
                var payload = {
                    notification: {
                        title: 'new Messages',
                        body: 'you have a new message',
                    },
                    data: {
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                        sendername: "Flash",
                        message: 'you have a new order',
                        title: 'New Order',



                    }
                };

                return admin.messaging().sendToDevice(contentDoc.pushToken, payload)
            }
        })
        .then((response) => {
            return console.log("Succesfully pushed");
        })
        .catch((error) => {
            console.log(error);
        })
})
var notificationDoc;

exports.notificationTrigger = functions.firestore.document(
    'Drivers Notifications/{autoId}'
).onCreate(async (snapshot, context) => {
    notificationDoc = snapshot.data();

    admin.firestore().collection('driversListeners').get()
        .then((snapshots) => {
            var tokens = [];
            if (snapshots.empty) {
                return console.log('No Devices');
            }
            else {
                for (var token of snapshots.docs) {
                    tokens.push(token.data().deviceToken);
                }
                var payload = {
                    notification: {
                        title: notificationDoc.title,
                        body: notificationDoc.body,
                        sound: "default"
                        
                    },
                    data: {
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                        sendername: "Flash",
                        message: notificationDoc.body,
                        title: notificationDoc.title,

                        



                    }
                };

                return admin.messaging().sendToDevice(tokens, payload)
            }
        })
        .then((response) => {
            return console.log("Succesfully pushed");
        })
        .catch((error) => {
            console.log(error);
        })
})

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
