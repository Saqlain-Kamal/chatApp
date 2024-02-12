import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/auth/widgets/messge_bubble.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/notifications/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IndividualChatScreen extends StatefulWidget {
  const IndividualChatScreen({super.key, required this.userId});
  final String userId;

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
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
                  Colors.orange.shade400
                ]),
          ),
        ),
        foregroundColor: Colors.white,
        title: CustomAppBar(widget: widget),
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
                const EdgeInsets.only(left: 15, bottom: 25, right: 15, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(width: 2, color: Colors.orange)),
                      enabled: true,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.orange)),
                      hintText: 'Enter message...',
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
                              await context.read<AuthController>().sendMessge(
                                  recieveId: widget.userId,
                                  text: messageController);
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
                            fontSize: 14,
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
