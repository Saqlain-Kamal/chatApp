import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/auth/widgets/messge_bubble.dart';
import 'package:chatapp/common/custom_button.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/notifications/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndividualChatScreen extends StatefulWidget {
  const IndividualChatScreen({super.key, required this.userId});
  final String userId;

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  bool isloading = false;
  List<String> _pendingMessages = [];
  AudioPlayer audioPlayer = AudioPlayer();
  final notification = NotificationServices();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<AuthController>(context, listen: false)
          .getUserById(uid: widget.userId);
      Provider.of<AuthController>(context, listen: false)
          .getAllMessages(recieverId: widget.userId);

      messageController.addListener(() {
        setState(() {
          // Update the state based on whether the messageController is empty or not
          isMessageEmpty = messageController.text.isEmpty;
          if (!isMessageEmpty) {
            print('hihihihihiih');
            context.read<AuthController>().updateUserStatus({'isTyping': true});
          } else {
            context
                .read<AuthController>()
                .updateUserStatus({'isTyping': false});
          }
        });
      });
    });
    notification.getRecieverToken(widget.userId);

    super.initState();
  }

  bool isMessageEmpty = true;
  final messageController = TextEditingController();

  Future<void> _loadPendingMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? pendingMessages = prefs.getStringList('pending_messages');
    if (pendingMessages != null) {
      setState(() {
        _pendingMessages = pendingMessages;
      });
    }
  }

  Future<void> _savePendingMessage(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _pendingMessages.add(message);
    await prefs.setStringList('pending_messages', _pendingMessages);
    setState(() {
      _pendingMessages = _pendingMessages;
    });
  }

  Future<void> _sendPendingMessages() async {
    for (String message in _pendingMessages) {
      // Send the pending message to Firebase
      // Your logic to send message to Firebase goes here

      // Remove the message from pending list after successfully sending to Firebase
      _pendingMessages.remove(message);
    }
    // Clear pending messages from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_messages');
    setState(() {
      _pendingMessages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // final messges = [
    //   Message(
    //       messge: 'Hi How are You',
    //       recieveId: widget.userId,
    //       sendId: context.read<AuthController>().appUser!.uid,
    //       sentTime: DateTime.now()),
    //   Message(
    //       messge: 'I Am Fine.. How are You ?',
    //       recieveId: context.read<AuthController>().appUser!.uid,
    //       sendId: widget.userId,
    //       sentTime: DateTime.now()),
    //   Message(
    //       messge: 'Hi How are You',
    //       recieveId: widget.userId,
    //       sendId: context.read<AuthController>().appUser!.uid,
    //       sentTime: DateTime.now()),
    //   Message(
    //       messge: 'Hi How are You',
    //       recieveId: context.read<AuthController>().appUser!.uid,
    //       sendId: widget.userId,
    //       sentTime: DateTime.nosw()),
    // ];
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.orange.shade600,
                  Colors.yellow.shade100
                ]),
          ),
        ),
        foregroundColor: Colors.white,
        title: CustomAppBar(widget: widget),
        actions: [
          context.watch<AuthController>().messages.isNotEmpty
              ? SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CustomButton(
                      isloading: isloading,
                      onTap: () async {
                        setState(() {
                          isloading = true;
                        });
                        print('1');
                        await context
                            .read<AuthController>()
                            .deleteMessages(receiverId: widget.userId);
                        print('2');
                        setState(() {
                          isloading = false;
                        });
                      },
                      text: 'Delete chat',
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Consumer<AuthController>(
            builder: (context, value, child) {
              print(value.messages.length);
              return value.messages.isNotEmpty
                  ? Expanded(
                      child: PageStorage(
                        bucket: PageStorageBucket(),
                        child: ListView.builder(
                          key: const PageStorageKey<String>('uniqueKey'),
                          controller: value.scrollController,
                          itemCount: value.messages.length,
                          itemBuilder: (context, index) {
                            final isMe = value.messages[index].sendId ==
                                context.read<AuthController>().appUser!.uid;
                            return MessgeBubble(
                              isMe: isMe,
                              message: value.messages[index],
                            );
                          },
                        ),
                      ),
                    )
                  : const Expanded(
                      child: Center(
                        child: Text('No Chat Yet !'),
                      ),
                    );
            },
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, bottom: 25, right: 10, top: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    maxLines: null,
                    minLines: 1,
                    controller: messageController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: 1.5, color: Colors.orange)),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              width: 0.5, color: Colors.black)),
                      hintText: 'Send message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color:
                        isMessageEmpty ? Colors.grey.shade300 : Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                      onPressed: isMessageEmpty
                          ? null
                          : () async {
                              await context
                                  .read<AuthController>()
                                  .initConnectivity();
                              await audioPlayer.play(
                                AssetSource('send.mp3'),
                              );
                              await context.read<AuthController>().sendMessge(
                                    recieveId: widget.userId,
                                    text: messageController,
                                  );
                              await notification.sendNotification(
                                  body: messageController.text,
                                  sendId:
                                      FirebaseAuth.instance.currentUser!.uid);

                              print('object');
                            },
                      icon: Icon(
                        Icons.send,
                        color: isMessageEmpty ? Colors.black : Colors.white,
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.widget,
  });

  final IndividualChatScreen widget;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, value, child) {
        final user = value.user;
        final time = value.user != null
            ? DateFormat('h:mm a').format(user!.lastSeen)
            : '';
        return user != null
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange.shade100,
                    child: Container(
                      height: screenHeight(context),
                      width: screenWidth(context),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: user.image ?? '',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.deepOrange,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        user.isOnline
                            ? user.isTyping
                                ? 'Typing...'
                                : 'Online'
                            : 'Last seen $time',
                        style: TextStyle(
                            fontSize: 12,
                            color: user.isOnline ? Colors.green : Colors.white),
                      ),
                    ],
                  )
                ],
              )
            : const SizedBox(); // Return an empty SizedBox if user is null
      },
    );
  }
}
