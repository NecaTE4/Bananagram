import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethod {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uid = Uuid().v4();

  Future<String> uploadImageToStorage(
      String name, File file) async {
    Reference ref =
        storage.ref().child(name).child(_auth.currentUser!.uid).child(uid);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }


}