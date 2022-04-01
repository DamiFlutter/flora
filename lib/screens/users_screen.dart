// ignore_for_file: must_call_super

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora/screens/new_message_screen.dart';
import 'package:flora/themes/colors.dart';
import 'package:flora/themes/styles.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email',
                  isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nearby Floras',
                              style: TextStyles.h2,
                            )
                          ],
                        ),
                        const Icon(
                          FlutterIcons.bell_fea,
                          size: 15,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot
                                    .data.docs[index]
                                    .data()['imageurl']),
                              ),
                              trailing: SizedBox(
                                height: 40,
                                width: 90,
                                child: OutlineButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => NewMessage(
                                                  peerId: snapshot.data
                                                      .docs[index]['userid'],
                                                  itmes: snapshot
                                                      .data.docs[index]
                                                      .data()['email'],
                                                )));
                                  },
                                  child: Text(
                                    'Message',
                                    style: GoogleFonts.raleway(
                                      color: AppColors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                snapshot.data.docs[index].data()['username'],
                                style: GoogleFonts.raleway(
                                  color: AppColors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    'last seen: ',
                                    style: GoogleFonts.andika(
                                      color: AppColors.grey3,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(snapshot.data.docs[index]
                                        .data()['lastseen']
                                        .toDate()),
                                    style: GoogleFonts.andika(
                                      color: AppColors.grey3,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: snapshot.data?.docs.length ?? 0),
                    ),
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
