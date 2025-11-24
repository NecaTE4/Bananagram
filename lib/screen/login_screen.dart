import 'package:bananagram/firebase_service/firebase_auth.dart';
import 'package:bananagram/screen/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../auth/auth_Screen.dart';
import '../widgets/loading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  Shader linearGradient = const LinearGradient(
    colors: <Color>[
      Color(0xFFF58529),
      Color(0xFFDD2A7B),
      Color(0xFF8134AF)
    ],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 100.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 100.h),
            Center(
              child: Text(
                'Bananagram',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontFamily: 'Billabong',
                  fontWeight: FontWeight.w400,
                  foreground: Paint()..shader = linearGradient,
                ),
              ),
            ),
            SizedBox(height: 80.h),

            TextFields(email, "Email"),

            TextFields(password, "Password", isPassword: true),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.sp),
                child: TextButton(
                  onPressed: () async {
                    if (email.text.isNotEmpty) {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password reset email sent, please check your email or spam")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter your email first")),
                      );
                    }
                  },
                  child: Text("Forgot password?", style: TextStyle(color: Colors.blueAccent, fontSize: 12.sp, fontWeight: FontWeight.w400)),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.r),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    FocusScope.of(context).unfocus();
                    setState(() => isLoading = true);
                    try {
                      await Authentication().login(
                        email: email.text.trim(),
                        password: password.text.trim(),
                      );

                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null && !user.emailVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please verify your email before logging in.")),
                        );
                        await FirebaseAuth.instance.signOut();
                        return;
                      }

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                        );
                      }
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                        );
                      }
                    } on SignUpFailure catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message)),
                      );
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: isLoading
                      ? const LoadingWidget()
                      : Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Have(),
          ],
        ),
      ),
    );
  }

  Padding TextFields(TextEditingController controller, String hintText,
      {bool isPassword = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 8.sp),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
          EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Row Have() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: Text(
            "Sign up",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
