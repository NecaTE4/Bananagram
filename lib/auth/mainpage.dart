import 'package:bananagram/auth/auth_Screen.dart';
import 'package:bananagram/widgets/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Mainpage extends StatelessWidget {
  const Mainpage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.hasData) {
          return const Scaffold(
            backgroundColor: Colors.white,
              body: Center(child: NavigationScreen()));
        }
        return const Scaffold(
          backgroundColor: Colors.white,
            body: Center(child: AuthScreen()));
      },
    );
  }

}
