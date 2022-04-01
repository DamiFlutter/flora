import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flora/constants/app_helpers.dart';
import 'package:flora/providers/auth_providers.dart';
import 'package:flora/themes/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .get(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: AppHelpers.kdefaultPadding * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(snapshot.data!['imageurl']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      snapshot.data!['username'],
                      style: TextStyles.h2,
                    ),
                    Text(
                      snapshot.data!['email'],
                      style: TextStyles.subtitl2,
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      onTap: () {
                        auth.signeOut();
                      },
                      // ignore: prefer_const_constructors
                      title: Text("Logout",
                          style: GoogleFonts.raleway(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
