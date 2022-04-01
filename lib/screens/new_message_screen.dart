import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flora/model/firebase_chat.dart';
import 'package:flora/providers/auth_providers.dart';
import 'package:flora/providers/chat_providers.dart';
import 'package:flora/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewMessage extends StatefulWidget {
  var itmes;

  String peerId;
  NewMessage({Key? key, required this.itmes, required this.peerId})
      : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String? groupchatId;

  final TextEditingController _editing = TextEditingController();
  List nearbyUsers = [];
  List quickChats = [
    'Hey',
    'Howdy!',
    'Hi',
    'Hey!',
    'Whats up?',
    'How are you?',
    'How are you doing?',
  ];
  void getId() {
    if (FirebaseAuth.instance.currentUser!.uid.compareTo(widget.peerId) > 0) {
      groupchatId =
          '${FirebaseAuth.instance.currentUser!.uid}-${widget.peerId}';
    } else {
      groupchatId =
          '${widget.peerId}-${FirebaseAuth.instance.currentUser!.uid}';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    var chatProvider = Provider.of<ChatProvider>(context);
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.itmes)
            .get(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // nearbyUsers.add(snapshot.data.data());
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            NetworkImage(snapshot.data.data()['imageurl']),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.data()['username'],
                            style: GoogleFonts.raleway(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            snapshot.data['lastseen'] == DateTime.now()
                                ? 'online'
                                : timeago.format(
                                    snapshot.data.data()['lastseen'].toDate()),
                            style: GoogleFonts.andika(
                              color: AppColors.grey3,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              centerTitle: false,
            ),
            body: StreamBuilder(
              stream: chatProvider.getChatStream(groupchatId ?? '', 20),
              builder: ((context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data.docs.length == 0) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'No Messages',
                          style: GoogleFonts.raleway(
                            color: AppColors.grey3,
                            fontSize: 15,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 88.0, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick chats',
                                style: GoogleFonts.raleway(
                                  color: AppColors.grey3,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Start a conversation with by tapping on a message',
                                style: GoogleFonts.raleway(
                                  color: AppColors.grey3,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 35,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: quickChats.map((e) {
                                    return Container(
                                      height: 70,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Center(
                                          child: Text(
                                            e,
                                            style: GoogleFonts.raleway(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]);
                }
                MessageChat messageChat = MessageChat.fromDocument(
                    snapshot.data.docs[snapshot.data.docs.length - 1]);
                return ListView.builder(
                  reverse: false,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    MessageChat messageChat =
                        MessageChat.fromDocument(snapshot.data.docs[index]);
                    if (messageChat.idFrom == auth.user.uid) {
                      // Right (my message)
                      return Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: BubbleSpecialThree(
                              text: messageChat.content,
                              color: AppColors.maincolor2,
                              tail: true,
                              textStyle:
                                  GoogleFonts.raleway(color: Colors.white),
                            ),
                          ),

                          // : messageChat.type == TypeMessage.image
                          //     // Image
                          //     ? Container(
                          //         child: OutlinedButton(
                          //           child: Material(
                          //             child: Image.network(
                          //               messageChat.content,
                          //               loadingBuilder:
                          //                   (BuildContext context,
                          //                       Widget child,
                          //                       ImageChunkEvent?
                          //                           loadingProgress) {
                          //                 if (loadingProgress == null)
                          //                   return child;
                          //                 return Container(
                          //                   decoration: BoxDecoration(
                          //                     color: AppColors.grey2,
                          //                     borderRadius:
                          //                         BorderRadius.all(
                          //                       Radius.circular(8),
                          //                     ),
                          //                   ),
                          //                   width: 200,
                          //                   height: 200,
                          //                   child: Center(
                          //                     child:
                          //                         CircularProgressIndicator(
                          //                       color: AppColors.maincolor,
                          //                       value: loadingProgress
                          //                                   .expectedTotalBytes !=
                          //                               null
                          //                           ? loadingProgress
                          //                                   .cumulativeBytesLoaded /
                          //                               loadingProgress
                          //                                   .expectedTotalBytes!
                          //                           : null,
                          //                     ),
                          //                   ),
                          //                 );
                          //               },
                          //               errorBuilder:
                          //                   (context, object, stackTrace) {
                          //                 return Material(
                          //                   child: Image.asset(
                          //                     'images/img_not_available.jpeg',
                          //                     width: 200,
                          //                     height: 200,
                          //                     fit: BoxFit.cover,
                          //                   ),
                          //                   borderRadius: BorderRadius.all(
                          //                     Radius.circular(8),
                          //                   ),
                          //                   clipBehavior: Clip.hardEdge,
                          //                 );
                          //               },
                          //               width: 200,
                          //               height: 200,
                          //               fit: BoxFit.cover,
                          //             ),
                          //             borderRadius: BorderRadius.all(
                          //                 Radius.circular(8)),
                          //             clipBehavior: Clip.hardEdge,
                          //           ),
                          //           onPressed: () {
                          //             // Navigator.push(
                          //             //   context,
                          //             //   // MaterialPageRoute(
                          //             //   //   builder: (context) =>
                          //             //   //       FullPhotoPage(
                          //             //   //     url: messageChat.content,
                          //             //   //   ),
                          //             //   // ),
                          //             // );
                          //           },
                          //           style: ButtonStyle(
                          //               padding: MaterialStateProperty.all<
                          //                   EdgeInsets>(EdgeInsets.all(0))),
                          //         ),
                          //         // margin: EdgeInsets.only(
                          //         //     bottom: isLastMessageRight(index)
                          //         //         ? 20
                          //         //         : 10,
                          //         //     right: 10),
                          //       )
                          //     // Sticker
                          //     : Container(
                          //         child: Image.asset(
                          //           'images/${messageChat.content}.gif',
                          //           width: 100,
                          //           height: 100,
                          //           fit: BoxFit.cover,
                          //         ),
                          //         // margin: EdgeInsets.only(
                          //         //     bottom: isLastMessageRight(index)
                          //         //         ? 20
                          //         //         : 10,
                          //         //     right: 10),
                          //       ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.end,
                      );
                    } else {
                      // Left (peer message)
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                // isLastMessageLeft(index)
                                //     ? Material(
                                //         child: Image.network(
                                //           widget.arguments.peerAvatar,
                                //           loadingBuilder: (BuildContext context,
                                //               Widget child,
                                //               ImageChunkEvent?
                                //                   loadingProgress) {
                                //             if (loadingProgress == null)
                                //               return child;
                                //             return Center(
                                //               child: CircularProgressIndicator(
                                //                 color:
                                //                     ColorConstants.themeColor,
                                //                 value: loadingProgress
                                //                             .expectedTotalBytes !=
                                //                         null
                                //                     ? loadingProgress
                                //                             .cumulativeBytesLoaded /
                                //                         loadingProgress
                                //                             .expectedTotalBytes!
                                //                     : null,
                                //               ),
                                //             );
                                //           },
                                //           errorBuilder:
                                //               (context, object, stackTrace) {
                                //             return Icon(
                                //               Icons.account_circle,
                                //               size: 35,
                                //               color: ColorConstants.greyColor,
                                //             );
                                //           },
                                //           width: 35,
                                //           height: 35,
                                //           fit: BoxFit.cover,
                                //         ),
                                //         borderRadius: BorderRadius.all(
                                //           Radius.circular(18),
                                //         ),
                                //         clipBehavior: Clip.hardEdge,
                                //       )
                                // : Container(width: 35),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: BubbleSpecialThree(
                                    isSender: false,
                                    text: messageChat.content,
                                    color: AppColors.grey2,
                                    tail: true,
                                    textStyle: GoogleFonts.raleway(
                                        color: Colors.white),
                                  ),
                                ),
                                // : messageChat.type == TypeMessage.image
                                //     ? Container(
                                //         child: TextButton(
                                //           child: Material(
                                //             child: Image.network(
                                //               messageChat.content,
                                //               loadingBuilder:
                                //                   (BuildContext context,
                                //                       Widget child,
                                //                       ImageChunkEvent?
                                //                           loadingProgress) {
                                //                 if (loadingProgress == null)
                                //                   return child;
                                //                 return Container(
                                //                   decoration: BoxDecoration(
                                //                     color: AppColors.grey2,
                                //                     borderRadius:
                                //                         BorderRadius.all(
                                //                       Radius.circular(8),
                                //                     ),
                                //                   ),
                                //                   width: 200,
                                //                   height: 200,
                                //                   child: Center(
                                //                     child:
                                //                         CircularProgressIndicator(
                                //                       color: AppColors
                                //                           .maincolor,
                                //                       value: loadingProgress
                                //                                   .expectedTotalBytes !=
                                //                               null
                                //                           ? loadingProgress
                                //                                   .cumulativeBytesLoaded /
                                //                               loadingProgress
                                //                                   .expectedTotalBytes!
                                //                           : null,
                                //                     ),
                                //                   ),
                                //                 );
                                //               },
                                //               errorBuilder: (context,
                                //                       object, stackTrace) =>
                                //                   Material(
                                //                 child: Image.asset(
                                //                   'images/img_not_available.jpeg',
                                //                   width: 200,
                                //                   height: 200,
                                //                   fit: BoxFit.cover,
                                //                 ),
                                //                 borderRadius:
                                //                     BorderRadius.all(
                                //                   Radius.circular(8),
                                //                 ),
                                //                 clipBehavior: Clip.hardEdge,
                                //               ),
                                //               width: 200,
                                //               height: 200,
                                //               fit: BoxFit.cover,
                                //             ),
                                //             borderRadius: BorderRadius.all(
                                //                 Radius.circular(8)),
                                //             clipBehavior: Clip.hardEdge,
                                //           ),
                                //           onPressed: () {
                                //             // Navigator.push(
                                //             //   context,
                                //             // //   MaterialPageRoute(
                                //             //     builder: (context) =>
                                //             //         FullPhotoPage(
                                //             //             url: messageChat
                                //             //                 .content),
                                //             //   ),
                                //             // );
                                //           },
                                //           style: ButtonStyle(
                                //               padding: MaterialStateProperty
                                //                   .all<EdgeInsets>(
                                //                       EdgeInsets.all(0))),
                                //         ),
                                //         margin: EdgeInsets.only(left: 10),
                                //       )
                                //     : Container(
                                //         child: Image.asset(
                                //           'images/${messageChat.content}.gif',
                                //           width: 100,
                                //           height: 100,
                                //           fit: BoxFit.cover,
                                //         ),
                                //         //   margin: EdgeInsets.only(
                                //         //       bottom:
                                //         //           isLastMessageRight(index)
                                //         //               ? 20
                                //         //               : 10,
                                //         //       right: 10),
                                //         // ),
                                //       )
                              ],
                            ),

                            // Time
                            // isLastMessageLeft(index)
                            //     ? Container(
                            //         child: Text(
                            //           DateFormat('dd MMM kk:mm').format(
                            //               DateTime.fromMillisecondsSinceEpoch(
                            //                   int.parse(
                            //                       messageChat.timestamp))),
                            //           style: TextStyle(
                            //               color: ColorConstants.greyColor,
                            //               fontSize: 12,
                            //               fontStyle: FontStyle.italic),
                            //         ),
                            //         margin: EdgeInsets.only(
                            //             left: 50, top: 5, bottom: 5),
                            //       )
                            //     : SizedBox.shrink()
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                      );
                    }
                  },
                );
              }),
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _editing,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                    hintText: 'Type a message',
                    hintStyle: GoogleFonts.raleway(
                      color: AppColors.grey3,
                      fontSize: 12,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        chatProvider.sendMessage(
                          content: _editing.text,
                          currentUserId: auth.user.uid,
                          groupChatId: groupchatId ?? '',
                          peerId: widget.peerId,
                          type: 'text',
                        );
                        _editing.clear();
                      },
                      icon: const Icon(Icons.send, color: Colors.black),
                      color: AppColors.grey3,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
