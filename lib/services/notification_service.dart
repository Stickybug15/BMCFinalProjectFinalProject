
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

    } on FirebaseException catch (e, stackTrace) {
      // Catch Firebase-specific errors
      log(
        'An error occurred during notification initialization: [${e.code}] ${e.message}',
        error: e,
        stackTrace: stackTrace,
        name: 'NotificationService',
      );
    } catch (e, stackTrace) {
      // Catch any other generic errors
      log(
        'An unexpected error occurred during notification initialization: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'NotificationService',
      );
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Get a reference to the user's document
        final userDocRef = _firestore.collection('users').doc(user.uid);

        // Get the document snapshot
        final userDoc = await userDocRef.get();

        // Get the existing tokens, or an empty list if it doesn't exist
        final List<dynamic> tokens = userDoc.exists && userDoc.data()!.containsKey('fcmTokens')
            ? List<dynamic>.from(userDoc.data()!['fcmTokens'] as List)
            : [];

        // Add the new token if it's not already in the list
        if (!tokens.contains(token)) {
          tokens.add(token);
          await userDocRef.set({'fcmTokens': tokens}, SetOptions(merge: true));
          log('FCM token saved to Firestore for user: ${user.uid}');
        }
      }
    } on FirebaseException catch (e) {
      log('Error saving FCM token to Firestore: [${e.code}] ${e.message}', name: 'NotificationService');
    } catch (e) {
      log('An unexpected error occurred while saving FCM token: $e', name: 'NotificationService');
    }
  }
}
