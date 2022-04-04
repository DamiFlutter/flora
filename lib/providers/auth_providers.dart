import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flora/constants/firestore_contants.dart';
import 'package:flora/model/firebase_chat.dart';
import 'package:timeago/timeago.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  AuthProvider(this._firebaseAuth);
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  bool _isLoggedIn = false;
  get user => _firebaseAuth.currentUser;
  bool get isLoggedIn => _isLoggedIn;

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  getUser() {
    return FirebaseAuth.instance.currentUser!;
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          savetofirestore(
            email: userCredential.user!.email ?? '',
            username: userCredential.user!.displayName ?? '',
            imageurl: userCredential.user!.photoURL ?? '',
            userid: userCredential.user!.uid,
            createdAt: DateTime.now(),
            lastseen: DateTime.now(),
          );

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // ...
          } else if (e.code == 'invalid-credential') {
            // ...
          }
        } catch (e) {
          // ...
        }
      }
    }

    return user;
  }

  Future<void> savetofirestore(
      {required String userid,
      String? username,
      DateTime? createdAt,
      required String email,
      DateTime? lastseen,
      String? imageurl}) async {
    return FirebaseFirestore.instance.collection('users').doc(email).set({
      'email': email,
      'username': username,
      'userid': userid,
      'imageurl': imageurl,
      'createdAt': createdAt ?? DateTime.now(),
      'lastseen': lastseen ?? false,
    });
  }

  Future updateLastSeen({
    required String active,
  }) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(getUser().email)
        .update({
      'active': active,
      'lastseen': DateTime.now(),
    });
  }

  Future updatePushToken() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(getUser().email)
        .update({
      'pushtoken': FirebaseMessaging.instance.getToken(),
    });
  }

  Future signeOut() {
    updateLastSeen(active: 'last seen: ${DateTime.now()}');
    return _firebaseAuth.signOut().then((value) {});
  }

  Future sendMessage(
      {required String message,
      required String receiverId,
      required String senderId}) async {
    await FirebaseFirestore.instance.collection('messages').add({
      'sender': senderId,
      'receiver': receiverId,
      'message': message,
      'createdAt': DateTime.now(),
    });
  }

  Future sendMessages(String content, String type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = FirebaseFirestore.instance
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
    return documentReference.get();
  }
}

Future deleteMessage({
  required String messageId,
}) async {
  await FirebaseFirestore.instance
      .collection('messages')
      .doc(messageId)
      .delete();
}
