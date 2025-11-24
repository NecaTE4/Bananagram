import 'dart:io';
import 'package:bananagram/firebase_service/firestore.dart';
import 'package:bananagram/firebase_service/storage.dart';
import 'package:bananagram/firebase_service/model/usermodel.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/img_cached.dart';

class EditProfileScreen extends StatefulWidget {
  final Usermodel user;
  const EditProfileScreen({required this.user, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final usernameController = TextEditingController();
  File? _newImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.user.username;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    String imageUrl = widget.user.profileImageUrl;

    if (_newImage != null) {
      imageUrl =
      await StorageMethod().uploadImageToStorage("profileImages", _newImage!);
    }

    await FirestoreService().updateUserData(
      username: usernameController.text.trim(),
      profileImageUrl: imageUrl,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 200.w,
                      height: 200.w,
                      color: Colors.grey[300],
                      child: _newImage != null
                          ? Image.file(_newImage!, fit: BoxFit.cover)
                          : CachedImage(widget.user.profileImageUrl),
                    ),
                  ),
                  Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            buildTextField(usernameController, "Username"),
          ],
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
}
