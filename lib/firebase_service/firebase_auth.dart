
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'firestore.dart';
import 'storage.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw SignUpFailure("Please fill all fields.");
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw SignUpFailure(e.message ?? "Login failed.");
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required String username,
    File? profileImage,
  }) async {
    String URL ;
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      throw SignUpFailure("Please fill all fields.");
    }
    if (password != confirmPassword) {
      throw SignUpFailure("Passwords do not match.");
    }
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (profileImage != null) {
        URL = await StorageMethod().uploadImageToStorage("profileImages", profileImage!);
      } else {
        URL = "";
      }

      await FirestoreService().isAddUserData(
        username: username,
        email: email,
        profileImageUrl:URL == "" ? "https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg" : URL,
      );


    } on FirebaseAuthException catch (e) {
      throw SignUpFailure(e.message ?? "Sign up failed.");
    }
  }
}class SignUpFailure implements Exception {
  final String message;
  SignUpFailure(this.message);
  @override
  String toString() => message;
}
