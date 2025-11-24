import 'package:bananagram/widgets/Post.dart';
import 'package:bananagram/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
        Colors.white,
          title: Text('Bananagram' ,style: TextStyle(
            fontSize: 36.sp,
            fontFamily: 'Billabong',
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          ),
        /*
          actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(CupertinoIcons.heart,size: 24.sp),
              color: Colors.black,
              onPressed: () {

              },
            ),
          ),
        ],
        */
      ),
      body: CustomScrollView(
      slivers: [
      StreamBuilder(
      stream: _firestore
          .collection('posts')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (!snapshot.hasData) {
                return Center(child: LoadingWidget());
              }
              return Post(snapshot.data!.docs[index].data());
            },
            childCount:
            snapshot.data == null ? 0 : snapshot.data!.docs.length,
          ),
        );
      },
    )
    ],
    ),
    );
  }
}