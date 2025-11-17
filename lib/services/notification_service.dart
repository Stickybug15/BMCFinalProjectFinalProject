
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initNotifications() async {
    try {
      // 1. Request Permission
      await _firebaseMessaging.requestPermission();

      // 2. Get the FCM Token
      final String? fcmToken = await _firebaseMessaging.getToken();
      log("FCM Token: $fcmToken");

      // 3. Save the token to Firestore for the current user
      if (fcmToken != null) {
        await _saveTokenToDatabase(fcmToken);
      }

      // 4. Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

      // 5. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
          // Here you could show a local notification using a package like
          // flutter_local_notifications if you want to.
        }
      });
    } on PlatformException catch (e) {
      log("Failed to initialize notifications: ${e.message}");
    } catch (e) {
      log("An unexpected error occurred during notification initialization: $e");
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      } catch (e) {
        log("Error saving FCM token to Firestore: $e");
      }
    }
  }
}
