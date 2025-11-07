// Part 1: Imports
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Part 2: Widget Definition
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. We use a StreamBuilder to listen for auth changes
    return StreamBuilder<User?>(
      // 2. This is the stream from Firebase
      stream: FirebaseAuth.instance.authStateChanges(),

      // 3. The builder runs every time the auth state changes
      builder: (context, snapshot) {
        // 4. If the snapshot is still loading, show a spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 5. If the snapshot has data, a user is logged in
        if (snapshot.hasData) {
          return const HomeScreen(); // Show the home screen
        }

        // 6. If the snapshot has no data, no user is logged in
        return const LoginScreen(); // Show the login screen
      },
    );
  }
}
