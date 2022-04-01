import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flora/constants/firestore_contants.dart';
import 'package:flora/model/firebase_chat.dart';

class ChatProvider {
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({
    required this.firebaseFirestore,
  });

  // String? getPref(String key) {
  //   return prefs.getString(key);
  // }

  // UploadTask uploadFile(File image, String fileName) {
  //   Reference reference = firebaseStorage.ref().child(fileName);
  //   UploadTask uploadTask = reference.putFile(image);
  //   return uploadTask;
  // }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: false)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(
      {required String content,
      required String type,
      required String groupChatId,
      required String currentUserId,
      required String peerId}) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
