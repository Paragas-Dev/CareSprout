import 'package:care_sprout/Auth/login.dart';
import 'package:care_sprout/home_screen.dart';
import 'package:care_sprout/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static Future<void> setOnboardComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _isOnboarding;

  @override
  void initState() {
    super.initState();
    _isOnboarding = _checkOnboardingStatus();
  }

  Future<bool> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingComplete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isOnboarding,
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool onboardingIsComplete = onboardingSnapshot.data ?? false;

        if (!onboardingIsComplete) {
          return const Onboarding();
        } else {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final user = authSnapshot.data;

              if (user != null && user.emailVerified) {
                return const HomeScreen();
              } else if (user == null) {
                return const Login();
              } else {
                return const Login();
              }
            },
          );
        }
      },
    );
  }
}
