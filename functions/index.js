const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyOnOrderStatusChange = functions.firestore
    .document("orders/{orderId}")
    .onUpdate(async (change, context) => {
      const newValue = change.after.data();
      const previousValue = change.before.data();

      if (newValue.status !== previousValue.status) {
        const userId = newValue.userId;
        const userRef = admin.firestore().collection("users").doc(userId);
        const userDoc = await userRef.get();

        if (userDoc.exists) {
          const payload = {
            notification: {
              title: "Order Status Updated",
              body: `Your order #${context.params.orderId.substring(0, 6)} is now ${newValue.status}`,
            },
            data: {
              orderId: context.params.orderId,
              screen: "/order_history"
            }
          };

          const fcmToken = userDoc.data().fcmToken;

          if (fcmToken) {
            try {
              await admin.messaging().sendToDevice(fcmToken, payload);
              console.log("Notification sent successfully");
            } catch (error) {
              console.log("Error sending notification:", error);
            }
          }


          await admin.firestore().collection("notifications").add({
            userId: userId,
            title: "Order Status Updated",
            body: `Your order #${context.params.orderId.substring(0, 6)} is now ${newValue.status}`,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            isRead: false,
            orderId: context.params.orderId,
          });
        }
      }
      return null;
    });
