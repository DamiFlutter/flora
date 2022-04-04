import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  String username;
  String imageurl;
  String active;
  var lastSeen;
  String peerId;
  NewMessage(
      {Key? key,
      required this.itmes,
      required this.peerId,
      required this.username,
      required this.imageurl,
      required this.lastSeen,
      required this.active})
      : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> with TickerProviderStateMixin {
  String? groupchatId;

  final TextEditingController _editing = TextEditingController();
  int _limit = 20;
  bool _isLoading = false;
  int addLimit = 26;
  String _search = '';
  List<QueryDocumentSnapshot> messages = [];
  List quickChats = [
    'Hey',
    'Howdy!',
    'Hi',
    'Hey!',
    'Whats up?',
    'How are you?',
    'How are you doing?',
  ];
  List sticker = [
    'https://media.giphy.com/media/euW6JDwrMn0BqyNC8t/giphy.gif',
    'https://media.giphy.com/media/euW6JDwrMn0BqyNC8t/giphy.gif',
    'https://media.giphy.com/media/mBdAMiGQmxHnzsdLUD/giphy.gif',
    'https://media.giphy.com/media/YCTmTLbcMQr42sig1i/giphy.gif',
    'https://media.giphy.com/media/vw8Tm2vokUwPq45fPd/giphy.gif',
    'https://media.giphy.com/media/UTkqTkDUCh1F9jlLRF/giphy.gif',
    'https://media.giphy.com/media/d7R3NprBVdELc3M0Ds/giphy.gif',
    'https://media.giphy.com/media/RfdkYfL7NnxolfuUht/giphy.gif',
    'https://media.giphy.com/media/yQXsYi6ZYm2RHeriHV/giphy.gif',
  ];

  final ImagePicker _picker = ImagePicker();
  void getId() {
    if (FirebaseAuth.instance.currentUser!.uid.compareTo(widget.peerId) > 0) {
      groupchatId =
          '${FirebaseAuth.instance.currentUser!.uid}-${widget.peerId}';
    } else {
      groupchatId =
          '${widget.peerId}-${FirebaseAuth.instance.currentUser!.uid}';
    }
  }

  final TextEditingController textEditingController = TextEditingController();

  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
    // focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit >= messages.length) {
      setState(() {
        _limit += addLimit;
      });
    }
  }

  File? _image;

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthProvider>(context);
    var chatProvider = Provider.of<ChatProvider>(context);

    // nearbyUsers.add(snapshot.data.data());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Feather.phone_call,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SearchScreen(),
              //   ),
              // );
            },
          ),
          IconButton(
            icon: const Icon(
              Feather.more_vertical,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MoreScreen(),
              //   ),
              // );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.imageurl),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: GoogleFonts.raleway(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.active == 'online'
                          ? 'Online'
                          : 'last seen:' +
                              timeago.format(widget.lastSeen.toDate()),
                      style: GoogleFonts.andika(
                        color: widget.active == 'online'
                            ? Colors.green
                            : Colors.grey,
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
      body: DefaultTabController(
        length: 2,
        child: StreamBuilder(
          stream: chatProvider.getChatStream(groupchatId ?? '', _limit),
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
                      padding: const EdgeInsets.only(bottom: 88.0, left: 10),
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
                                return GestureDetector(
                                  onTap: () {
                                    chatProvider.sendMessage(
                                      content: e,
                                      currentUserId: auth.user.uid,
                                      groupChatId: groupchatId ?? '',
                                      peerId: widget.peerId,
                                      type: 'text',
                                    );
                                    listScrollController.animateTo(0,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut);
                                    _editing.clear();
                                  },
                                  child: Container(
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
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: listScrollController,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      MessageChat messageChat =
                          MessageChat.fromDocument(snapshot.data.docs[index]);
                      if (messageChat.idFrom == auth.user.uid) {
                        TimeOfDay time = TimeOfDay.fromDateTime(
                            DateTime.fromMicrosecondsSinceEpoch(
                                int.parse(messageChat.timestamp)));
                        // Right (my message)
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  messageChat.type == 'text'
                                      ? GestureDetector(
                                          onDoubleTap: () {
                                            print('double tapped');
                                            chatProvider.deleteMessage(
                                                groupchatId!,
                                                snapshot.data.docs[index].id);
                                            print(snapshot.data.docs[index].id);
                                          },
                                          child: BubbleSpecialThree(
                                            isSender: true,
                                            text: messageChat.content,
                                            color: AppColors.maincolor2,
                                            tail: true,
                                            textStyle: GoogleFonts.raleway(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        )
                                      : messageChat.type == 'sticker'
                                          ? GestureDetector(
                                              onDoubleTap: () {
                                                chatProvider.deleteMessage(
                                                    groupchatId!,
                                                    snapshot
                                                        .data.docs[index].id);
                                              },
                                              child: Container(
                                                height: 90,
                                                width: 90,
                                                child: Image.network(
                                                  messageChat.content,
                                                  fit: BoxFit.cover,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Image.network(
                                                    messageChat.content,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      time.format(context),
                                                      style: GoogleFonts.arimo(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    const Icon(
                                                        FlutterIcons.check_ant,
                                                        color: Colors.black,
                                                        size: 15),
                                                  ],
                                                ),
                                              ],
                                            ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Left (peer message)
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
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
                                    messageChat.type == 'text'
                                        ? BubbleSpecialThree(
                                            isSender: false,
                                            text: messageChat.content,
                                            color: AppColors.grey2,
                                            tail: true,
                                            textStyle: GoogleFonts.raleway(
                                                color: Colors.white),
                                          )
                                        : messageChat.type == 'sticker'
                                            ? Container()
                                            : Column(
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        onError: (exception,
                                                            stackTrace) {
                                                          print(exception);
                                                        },
                                                        image:
                                                            CachedNetworkImageProvider(
                                                                messageChat
                                                                    .content),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(10),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 5,
                                                          spreadRadius: 1,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const Icon(
                                                      Icons.verified_rounded,
                                                      color: Colors.black,
                                                      size: 20),
                                                ],
                                              )
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
                                    //                     color: AppColors.grey2,omor
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
                          margin: const EdgeInsets.only(bottom: 10),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 80),
                // Image.network(
                //     'https://media.giphy.com/media/RfdkYfL7NnxolfuUht/giphy.gif'),
              ],
            );
          }),
        ),
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
            onSubmitted: (sub) {
              if (sub.isNotEmpty) {
                chatProvider.sendMessage(
                  content: _editing.text,
                  currentUserId: auth.user.uid,
                  groupChatId: groupchatId ?? '',
                  peerId: widget.peerId,
                  type: 'text',
                );
                listScrollController.animateTo(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
                _editing.clear();
              }
            },
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              border: InputBorder.none,
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
                  IconButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: CupertinoColors.systemGreen,
                            content: Row(
                              children: const <Widget>[
                                CircularProgressIndicator(),
                                Text(' Sending Image...')
                              ],
                            ),
                          ),
                        );
                        final pickedFile =
                            await _picker.getImage(source: ImageSource.gallery);

                        File image;
                        if (pickedFile != null) {
                          image = File(pickedFile.path);
                          await uploadFile(chatProvider, image, auth, true);
                          listScrollController.animateTo(0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        } else {
                          print('No image selected.');
                          return;
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                      icon: const Icon(Icons.image)),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return DefaultTabController(
                                length: 3,
                                child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Stickers',
                                            style: GoogleFonts.raleway(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const TabBar(
                                          indicatorColor: AppColors.maincolor2,
                                          labelColor: AppColors.maincolor2,
                                          unselectedLabelColor: AppColors.grey3,
                                          tabs: [
                                            Tab(
                                              text: 'Stickers',
                                            ),
                                            Tab(
                                              text: 'Emoji',
                                            ),
                                            Tab(
                                              text: 'Bitmoji',
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: TabBarView(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GridView.builder(
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                                itemBuilder: (context, index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      chatProvider.sendMessage(
                                                        content: sticker[index],
                                                        currentUserId:
                                                            auth.user.uid,
                                                        groupChatId:
                                                            groupchatId ?? '',
                                                        peerId: widget.peerId,
                                                        type: 'sticker',
                                                      );
                                                      listScrollController
                                                          .animateTo(0,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              curve: Curves
                                                                  .easeOut);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      child: Image.network(
                                                          sticker[index]),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                    ),
                                                  );
                                                },
                                                itemCount: sticker.length,
                                              ),
                                            ),
                                            Container(),
                                            Container(),
                                          ]),
                                        )
                                      ],
                                    )),
                              );
                            });
                      },
                      icon: const Icon(Icons.face)),
                ],
              ),
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
                  listScrollController.animateTo(0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
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
  }

  Future uploadFile(ChatProvider chatProvider, File imageFile,
      AuthProvider auth, bool isLoading) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      var imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
      });
      chatProvider.sendMessage(
        content: imageUrl,
        currentUserId: auth.user.uid,
        groupChatId: groupchatId ?? '',
        peerId: widget.peerId,
        type: 'image',
      );
      if (kDebugMode) {
        print('Image uploaded');
      }
    } on FirebaseException {
      setState(() {
        isLoading = false;
      });
    }
  }
}
