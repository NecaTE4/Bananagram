import 'package:bananagram/screen/feed_screen.dart';
import 'package:bananagram/screen/login_screen.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/navigation.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: LoadingWidget(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const NavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
