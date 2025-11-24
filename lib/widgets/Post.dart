import 'dart:io';
import 'dart:math';
import 'package:bananagram/screen/profile_screen.dart';
import 'package:bananagram/widgets/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../firebase_service/firestore.dart';

class Post extends StatefulWidget {
  final Map<String, dynamic> snapshot;
  const Post(this.snapshot, {super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> with SingleTickerProviderStateMixin {
  bool _isAnimating = false;
  late AnimationController _controller;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  String user = '';

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser?.uid ?? '';
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() async {
    setState(() => _isAnimating = true);
    await _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.snapshot['postId'];

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _firestoreService.getPostStream(postId),
      builder: (context, postSnap) {
        if (!postSnap.hasData || !postSnap.data!.exists) {
          return const SizedBox.shrink();
        }

        final snapshot = postSnap.data!.data()!;
        final likes = List<String>.from(snapshot['like'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('comments')
              .snapshots(),
          builder: (context, commentSnap) {
            int totalComments = commentSnap.data?.docs.length ?? 0;
            Map<String, dynamic>? randomComment;
            if (totalComments > 0) {
              randomComment =
                  (commentSnap.data!.docs[Random().nextInt(totalComments)]
                          .data()
                      as Map<String, dynamic>);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                ListTile(
                  leading: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(snapshot['uid']),
                      ),
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot['uid'])
                          .snapshots(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) {
                          return CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.grey[300],
                          );
                        }
                        final userData =
                            userSnap.data!.data() as Map<String, dynamic>;
                        return CircleAvatar(
                          radius: 20.r,
                          backgroundImage: CachedNetworkImageProvider(
                            userData['profileImageUrl'] ?? '',
                          ),
                        );
                      },
                    ),
                  ),
                  title: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot['uid'])
                        .snapshots(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const SizedBox();
                      final userData =
                          userSnap.data!.data() as Map<String, dynamic>;
                      return Text(
                        userData['username'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  trailing: GestureDetector(
                    onTap: () async {
                      try {
                        final imageUrl = snapshot['postImage'];

                        final response = await http.get(Uri.parse(imageUrl));

                        final tempDir = await getTemporaryDirectory();
                        final filePath = '${tempDir.path}/downloaded_image.jpg';
                        final file = File(filePath);
                        await file.writeAsBytes(response.bodyBytes);

                        await GallerySaver.saveImage(file.path);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Image saved to gallery")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to save image: $e")),
                        );
                      }
                    },
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 24.w,
                      color: Colors.black,
                    ),
                  ),
                ),

                // POST IMAGE
                GestureDetector(
                  onDoubleTap: () async {
                    if (!likes.contains(user)) {
                      await _firestoreService.toggleLike(postId);
                      _triggerLikeAnimation();
                    } else {
                      _triggerLikeAnimation();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 375.w,
                        color: Colors.grey[300],
                        child: Image(
                          image: CachedNetworkImageProvider(
                            snapshot['postImage'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_isAnimating)
                        FadeTransition(
                          opacity: ReverseAnimation(
                            CurvedAnimation(
                              parent: _controller,
                              curve: const Interval(
                                0.7,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                          child: Lottie.asset(
                            'assets/animations/like_banana.json',
                            controller: _controller,
                            width: 200.w,
                            height: 200.w,
                            onLoaded: (composition) {
                              _controller.duration = composition.duration;
                              _controller.forward(from: 0);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // INFO SECTION
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LIKE ROW
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!likes.contains(user)) {
                                  _firestoreService.toggleLike(postId);
                                  _triggerLikeAnimation();
                                } else {
                                  _firestoreService.toggleLike(postId);
                                }
                              },
                              child: Image.asset(
                                likes.contains(user)
                                    ? 'assets/images/bananas_like.png'
                                    : 'assets/images/bananas_like_empty.png',
                                width: 24.w,
                                height: 24.h,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              likes.length.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 18.w),
                            GestureDetector(
                              onTap: () => _openComments(context, postId),
                              child: Image.asset(
                                'assets/images/apes_comme.png',
                                width: 24.w,
                                height: 24.h,
                              ),
                            ),
                            if (totalComments > 0) ...[
                              SizedBox(width: 6.w),
                              Text(
                                totalComments.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // CAPTION
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${snapshot['username']} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              TextSpan(
                                text: snapshot['caption'],
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // RANDOM COMMENT
                      if (randomComment != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 2.h,
                            bottom: 1.h,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: '${randomComment['username']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: randomComment['comment']),
                              ],
                            ),
                          ),
                        ),

                      // VIEW COMMENTS
                      if (totalComments > 0)
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 0.h,
                          ),
                          child: GestureDetector(
                            onTap: () => _openComments(context, postId),
                            child: Text(
                              'View all $totalComments comments',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                height: 1,
                              ),
                            ),
                          ),
                        ),

                      // TIME
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          convertTime(snapshot['time'].toDate()),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openComments(BuildContext context, String postId) {
    showBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            maxChildSize: 0.5,
            initialChildSize: 0.5,
            minChildSize: 0.2,
            builder: (context, scrollController) {
              return Comment('posts', postId);
            },
          ),
        );
      },
    );
  }

  String convertTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays >= 1) {
      return '${dateTime.day} ${convertMonth(dateTime.month)} ${dateTime.year}';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String convertMonth(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
