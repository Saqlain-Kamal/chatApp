import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:flutter/material.dart';

class IndividualChatScreen extends StatefulWidget {
  const IndividualChatScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  @override
  Widget build(BuildContext context) {
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
              itemCount: 50,
              itemBuilder: (context, index) {
                return const Text('data');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
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
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
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
