import 'package:bananagram/firebase_service/firestore.dart';
import 'package:bananagram/firebase_service/model/usermodel.dart';
import 'package:bananagram/screen/profile_edit_screen.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/img_cached.dart';
import 'PostDetailScreen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen(this.uid, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int postCount = 0;

  bool get isMyProfile => widget.uid == _auth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(widget.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                  height: 20, width: 20, child: LoadingWidget());
            }

            final rawData = snapshot.data?.data();
            final userData = rawData != null
                ? Map<String, dynamic>.from(rawData as Map)
                : <String, dynamic>{};

            if (userData.isEmpty) {
              return const Text(
                'Unknown User',
                style: TextStyle(color: Colors.black),
              );
            }

            return Text(
              userData['username'] ?? 'No Name',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26.sp,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
        actions: [
          if (isMyProfile)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: IconButton(
                icon: Icon(Icons.power_settings_new, size: 28.sp),
                color: const Color(0xFF8F0C00),
                onPressed: () async {
                  showDialog(context: context, builder: (context) {
                    return CustomAlertDialog();
                  });
                },
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(widget.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: LoadingWidget());
                  }

                  final rawData = snapshot.data?.data();
                  final userData = rawData != null
                      ? Map<String, dynamic>.from(rawData as Map)
                      : <String, dynamic>{};

                  if (userData.isEmpty) {
                    return const Center(
                      child: Text(
                        'User data not found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final userModel = Usermodel(
                    userData['email'] ?? '',
                    userData['profileImageUrl'] ?? '',
                    userData['username'] ?? '',
                  );
                  return Head(userModel);
                },
              ),
            ),

            StreamBuilder(
              stream: _firestore
                  .collection('posts')
                  .where('uid', isEqualTo: widget.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                      child: Center(child: LoadingWidget()));
                }

                postCount = snapshot.data!.docs.length;

                if (postCount == 0) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.h),
                      child: const Center(
                        child: Text(
                          "No posts yet 🍌",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var postData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(postData),
                            ),
                          );
                        },
                        child: CachedImage(postData['postImage']),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4.h,
                    crossAxisSpacing: 4.w,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget Head(Usermodel usermodel) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    color: Colors.transparent,
                    child: CachedImage(usermodel.profileImageUrl),
                  ),
                ),
                SizedBox(width: 100.w),
                Column(
                  children: [
                    Text(
                      postCount.toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "bananas",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              width: double.infinity,
              height: 32.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: GestureDetector(
                onTap: () async {
                  if (isMyProfile) {
                    final user = await FirestoreService().getUser();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Follow feature coming soon!")),
                    );
                  }
                },
                child: Center(
                  child: Text(
                    isMyProfile ? 'Edit Your Profile' : 'Follow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Icon(Icons.grid_on, size: 24.sp, color: Colors.black),
          Divider(height: 10.h, thickness: 1.h, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget CustomAlertDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36.r),
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LOGOUT',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 8.h, thickness: 1.h, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _auth.signOut();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
