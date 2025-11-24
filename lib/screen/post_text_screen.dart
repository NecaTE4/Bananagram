import 'dart:io';
import 'package:bananagram/widgets/loading.dart';
import 'package:bananagram/widgets/navigation.dart';
import 'package:bananagram/firebase_service/firestore.dart';
import 'package:bananagram/firebase_service/storage.dart';
import 'package:bananagram/screen/feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostTextScreen extends StatefulWidget {
  File file;
  PostTextScreen(this.file, {super.key});

  @override
  State<PostTextScreen> createState() => _PostTextScreenState();
}

class _PostTextScreenState extends State<PostTextScreen> {
  final caption = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'new post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Billabong',
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      String post_url = await StorageMethod()
                          .uploadImageToStorage("post", widget.file);
                      await FirestoreService().CreatePost(
                        postImage: post_url,
                        caption: caption.text,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NavigationScreen(initialPage: 0),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: LoadingWidget())
            : Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.h,
                      margin: EdgeInsets.only(left: 16.w, right: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: FileImage(widget.file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        width: 200.w,
                        height: 100.h,
                        margin: EdgeInsets.only(right: 16.w),
                        child: TextField(
                          controller: caption,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none,
                          ),
                          cursorColor: Colors.black,
                          cursorRadius: Radius.circular(16.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
