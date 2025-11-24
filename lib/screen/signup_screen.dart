import 'dart:io';
import 'package:bananagram/firebase_service/firebase_auth.dart';
import 'package:bananagram/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final passwordConfirm = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  pickImage(ImageSource source) async {

    if (source == ImageSource.camera) {
      var status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission denied")),
        );
        return;
      }
    } else if (source == ImageSource.gallery) {
      var status = await Permission.photos.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gallery permission denied")),
        );
        return;
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Text(
                'Bananagram',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontFamily: 'Billabong',
                  fontWeight: FontWeight.w400,
                  foreground: Paint()..shader = linearGradient,
                ),
              ),
              SizedBox(height: 20.h),

              GestureDetector(
                onTap: _showImagePickerOptions, // alt popup aç
                child: CircleAvatar(
                  radius: 56.r,
                  backgroundColor: Colors.grey[600],
                  child: CircleAvatar(
                    radius: 54.r,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Icon(Icons.person,
                        size: 52.r, color: Colors.grey[600])
                        : null,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              buildTextField(email, "Email"),
              buildTextField(username, "Username"),
              buildTextField(password, "Password", isObscure: true),
              buildTextField(passwordConfirm, "Confirm Password",
                  isObscure: true),

              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0.r),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final userEmail = email.text.trim();
                      final userPassword = password.text.trim();
                      final confirmPass = passwordConfirm.text.trim();

                      // 1. Email format kontrolü
                      if (!userEmail.contains('@') || !userEmail.contains('.')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid email address")),
                        );
                        return;
                      }

                      // 2. Şifre eşleşmesi kontrolü
                      if (userPassword != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Passwords do not match")),
                        );
                        return;
                      }

                      // 3. neonapps.co domain kontrolü
                      if (userEmail.endsWith('@neonapps.co')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nice! Using your neonapps.co account.")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("You can also register with other emails.")),
                        );
                      }

                      // 4. Firebase signup işlemi + verification maili
                      try {
                        await Authentication().signup(
                          email: userEmail,
                          password: userPassword,
                          confirmPassword: confirmPass,
                          username: username.text.trim(),
                          profileImage: _profileImage,
                        );

                        // ✅ Email verification gönder
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && !user.emailVerified) {
                          await user.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Verification email sent. Please check your inbox.")),
                          );
                        }

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      } on SignUpFailure catch (e) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Sign Up Error"),
                            content: Text(e.message),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            title: Text("Sign Up Error"),
                            content: Text("Unexpected error"),
                          ),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
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
              haveAccount(),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildTextField(TextEditingController controller, String hintText,
      {bool isObscure = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 8.sp),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
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

  Row haveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Do you have an account? ",
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            "Log in",
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
