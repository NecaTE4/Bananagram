import 'package:bananagram/firebase_service/firestore.dart';
import 'package:bananagram/utils/img_cached.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Comment extends StatefulWidget {
  String type;
  String uid;
  Comment(this.type, this.uid, {super.key});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.white,
        height: 300,
        child: Stack(
          children: [
            Positioned(
              top: 8.h,
              left: 140.w,
              child: Container(width: 100.w, height: 3.h, color: Colors.black),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(widget.type)
                  .doc(widget.uid)
                  .collection('comments')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 70.h, top: 20.h),
                    itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingWidget());
                  }
                  return comment_item(snapshot.data!.docs[index].data());
                                },
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 44.h,
                    maxHeight: 120.h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                            ),
                            style: TextStyle(fontSize: 13.5.sp),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_commentController.text.isNotEmpty) {
                              await FirestoreService().Comments(
                                comment: _commentController.text,
                                type: widget.type,
                                uidd: widget.uid,
                              );
                              _commentController.clear();
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 6.w, bottom: 4.h),
                            child: Icon(Icons.send_rounded,
                                color: Colors.black87, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

  }
  Widget comment_item(final snapshot){
    return ListTile(
      leading: ClipOval(
        child: SizedBox(
            width: 48.w,
            height: 48.h,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot['uid'])
                  .snapshots(),
              builder: (context, userSnap) {
                String img = snapshot['profileImage']; // fallback
                if (userSnap.hasData && userSnap.data!.exists) {
                  final userData = userSnap.data!.data() as Map<String, dynamic>;
                  img = userData['profileImageUrl'] ?? img;
                }

                return ClipOval(
                  child: SizedBox(
                    width: 48.w,
                    height: 48.h,
                    child: CachedImage(img),
                  ),
                );
              },
            ),),
      ),
      title: Text(snapshot['username'], style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600,color: Colors.black)),
      subtitle: Text(snapshot['comment'], style: TextStyle(fontSize: 14.sp)),
    );
  }
}
