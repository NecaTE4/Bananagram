import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'model/usermodel.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isAddUserData({
    required String username,
    required String email,
    required String profileImageUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'username': username,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add user data: $e");
    }
    return true;
  }
  Future<Usermodel> getUser({String? UID}) async {
    try {
      final user = await _firestore
          .collection('users')
          .doc(UID ?? _auth.currentUser!.uid)
          .get();

      final snapuser = user.data()!;
      return Usermodel(
        snapuser['email'] ?? '',
        snapuser['profileImageUrl'] ?? '',
        snapuser['username'] ?? '',
      );
    } on FirebaseException catch (e) {
      throw (e.message.toString());
    }
  }

  //Firebase içinde yorum listesi tutmak?
  Future<bool> CreatePost({
    required String postImage,
    required String caption,
  }) async {
    var uid = Uuid().v4();
    DateTime data = new DateTime.now();
    Usermodel user = await getUser();
    await _firestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user.username,
      'profileImage': user.profileImageUrl,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }
  Future<void> updateUserData({
    required String username,
    required String profileImageUrl,
  }) async {
    final currentUid = _auth.currentUser!.uid;

    // 1️⃣ Kullanıcının kendi Firestore dokümanını güncelle
    await _firestore.collection('users').doc(currentUid).update({
      'username': username,
      'profileImageUrl': profileImageUrl,
    });

    // 2️⃣ Tüm postlar içindeki yorumlarda o kullanıcıya ait olanları bul
    final posts = await _firestore.collection('posts').get();

    for (var post in posts.docs) {
      final commentsRef = post.reference.collection('comments');

      // Sadece güncellenen kullanıcıya ait yorumları bul
      final userComments = await commentsRef.where('uid', isEqualTo: currentUid).get();

      for (var comment in userComments.docs) {
        // Her yorumu yeni kullanıcı bilgileriyle güncelle
        await comment.reference.update({
          'username': username,
          'profileImage': profileImageUrl,
        });
      }
    }

    // (Opsiyonel) Eğer kullanıcı kendi postlarını da güncellensin istiyorsan:
    final userPosts =
    await _firestore.collection('posts').where('uid', isEqualTo: currentUid).get();

    for (var post in userPosts.docs) {
      await post.reference.update({
        'username': username,
        'profileImage': profileImageUrl,
      });
    }
  }

  Future<bool> Comments({
    required String comment,
    required String type,
    required String uidd,
  }) async {
    var uid = Uuid().v4();
    Usermodel user = await getUser();

    await _firestore
        .collection(type)
        .doc(uidd)
        .collection('comments')
        .doc(uid)
        .set({
      'comment': comment,
      'username': user.username,
      'profileImage': user.profileImageUrl,
      'uid': _auth.currentUser!.uid,
      'CommentUid': uid,
      'postId': uidd,
      'createdAt': FieldValue.serverTimestamp(),
    });


    return true;
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser?.uid;
    if (user == null || user.isEmpty) return;

    final postRef = _firestore.collection('posts').doc(postId);
    final doc = await postRef.get();
    List likes = doc['like'] ?? [];

    if (likes.contains(user)) {
      await postRef.update({
        'like': FieldValue.arrayRemove([user]),
      });
    } else {
      await postRef.update({
        'like': FieldValue.arrayUnion([user]),
      });
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getPostStream(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots();
  }
  Future<bool> hasLiked(String postId) async {
    final user = _auth.currentUser?.uid;
    if (user == null || user.isEmpty) return false;
    final doc = await _firestore.collection('posts').doc(postId).get();
    List likes = doc['like'] ?? [];
    return likes.contains(user);
  }
}
