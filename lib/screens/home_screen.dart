import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora/model/chats.dart';
import 'package:flora/themes/colors.dart';
import 'package:flora/themes/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flora/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: ((context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chats',
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
                    const SearchBar(hintText: 'Search for a chat'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Broadcast Groups',
                          style: TextStyles.subtitle,
                        ),
                        Text(
                          'New Group',
                          style: TextStyles.subtitl2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Text(
                      'Recent Chats',
                      style: TextStyles.h2,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                            AssetImage(users[index].image),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(users[index].name,
                                              style: GoogleFonts.raleway(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600)),
                                          Text(users[index].messages,
                                              style: TextStyles.subtitl2),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        child: Center(
                                          child: Text(
                                            users[index].time.toString(),
                                            style: const TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.white),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.black,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                      ),
                                      Text(
                                        timeago.format(DateTime.now().subtract(
                                            Duration(
                                                hours: users[index].time))),
                                        style: TextStyles.subtitl2,
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            );
          })),
    );
  }
}
