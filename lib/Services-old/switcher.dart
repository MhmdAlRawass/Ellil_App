import 'package:audio_app_example/screens/auth/login.dart';
import 'package:audio_app_example/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Switcher extends StatelessWidget {
  const Switcher({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If user is logged in
        if (snapshot.hasData) {
          return const TabsScreen();
        }

        // If user is not logged in
        return const LoginPage();
      },
    );
  }
}
