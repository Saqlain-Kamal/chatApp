import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/auth/widgets/messge_bubble.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/model/message_model.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IndividualChatScreen extends StatefulWidget {
  const IndividualChatScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  @override
  void initState() {
    messageController.addListener(() {
      setState(() {
        // Update the state based on whether the messageController is empty or not
        isMessageEmpty = messageController.text.isEmpty;
      });
    });
    super.initState();
  }

  bool isMessageEmpty = true;
  final messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final messges = [
      Message(
          messge: 'Hi How are You',
          recieveId: widget.user.uid,
          sendId: context.read<AuthController>().appUser!.uid,
          sentTime: DateTime.now()),
      Message(
          messge: 'I Am Fine.. How are You ?',
          recieveId: context.read<AuthController>().appUser!.uid,
          sendId: widget.user.uid,
          sentTime: DateTime.now()),
      Message(
          messge: 'Hi How are You',
          recieveId: widget.user.uid,
          sendId: context.read<AuthController>().appUser!.uid,
          sentTime: DateTime.now()),
      Message(
          messge: 'Hi How are You',
          recieveId: context.read<AuthController>().appUser!.uid,
          sendId: widget.user.uid,
          sentTime: DateTime.now()),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            widget.user.image != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange.shade100,
                    child: Container(
                      height: screenHeight(context),
                      width: screenWidth(context),
                      // margin: EdgeInsets.all(5),
                      // padding: EdgeInsets.all(5),
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.user.image!,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.deepOrange,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  )
                : const CircleAvatar(
                    radius: 25,
                  ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  widget.user.isOnline ? 'Online' : 'Ofline',
                  style: TextStyle(
                      fontSize: 14,
                      color: widget.user.isOnline ? Colors.green : Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messges.length,
              itemBuilder: (context, index) {
                final isMe = messges[index].sendId ==
                    context.read<AuthController>().appUser!.uid;
                return MessgeBubble(
                  isMe: isMe,
                  message: messges[index],
                );
              },
            ),
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
                      hintText: 'Enter Message',
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
                          : () {
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
