const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggered when a new Payment document is created in the 'payments' collection.
 * Sends a Push Notification to the Tenant who made the payment.
 */
exports.sendPaymentNotification = functions.firestore
  .document("payments/{paymentId}")
  .onCreate(async (snap, context) => {
    const payment = snap.data();

    // 1. Get Details from Payment
    const tenantId = payment.tenantId; // int
    const amount = payment.amount;
    const notes = payment.notes || "";

    // 2. Find Tenant by ID (integer)
    const tenantSnapshot = await admin.firestore()
      .collection("tenants")
      .where("id", "==", tenantId)
      .limit(1)
      .get();

    if (tenantSnapshot.empty) {
      console.log(`No tenant found for ID: ${tenantId}`);
      return null;
    }

    const tenantData = tenantSnapshot.docs[0].data();
    // 3. Get FCM Token Directly from Tenant Document
    const fcmToken = tenantData.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM Token for Tenant ${tenantId}. Tenant may not have logged in recently.`);
      return null;
    }

    // 4. Send Notification
    const payload = {
      notification: {
        title: "Payment Received",
        body: `We have received your payment of ₹${amount}. Thank you!`,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        route: "/tenant/dashboard", // Deep link equivalent
        paymentId: context.params.paymentId,
      },
      token: fcmToken,
    };

    try {
      await admin.messaging().send(payload);
      console.log("Notification sent successfully.");
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });
