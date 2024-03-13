import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/model/message_model.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:chatapp/screens/individual_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SingleUser extends StatefulWidget {
  const SingleUser({
    Key? key,
    required this.user,
    required this.lastMessage,
    required this.readOrUnread,
  }) : super(key: key);

  final UserModel user;
  final String lastMessage;
  final bool readOrUnread; // Non-nullable

  @override
  State<SingleUser> createState() => _SingleUserState();
}

class _SingleUserState extends State<SingleUser> {
  late List<Message> messages; // Track messages
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    // Fetch all messages initially
    fetchMessages();
  }

  // Method to fetch all messages
  void fetchMessages() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    try {
      // Call the method to fetch messages
      messages = await Provider.of<AuthController>(context, listen: false)
          .getAllMessages(recieverId: widget.user.uid);

      setState(() {
        isLoading = false; // Set loading state to false after fetching messages
      });
    } catch (e) {
      // Handle any errors
      print('Error fetching messages: $e');
      setState(() {
        isLoading = false; // Set loading state to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.user.image);
    String formattedDate = DateFormat.Hm().format(widget.user.lastSeen);
    return GestureDetector(
      onTap: () {
        print(widget.user.name);
        print('object');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualChatScreen(
              userId: widget.user.uid,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: Colors.orange.shade100,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              widget.user.image != null
                  ? CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange.shade100,
                      child: Container(
                        height: screenHeight(context),
                        width: screenWidth(context),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: widget.user.image!,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.deepOrange,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange.shade300,
                    ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Consumer<AuthController>(
                  builder: (context, value, child) {
                    final user = value.user;
                    return user != null && widget.user.isOnline
                        ? Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: Colors.white),
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            width: 15,
                            height: 15,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: Colors.white),
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            width: 15,
                            height: 15,
                          );
                  },
                ),
              )
            ],
          ),
          title: Text(widget.user.name),
          subtitle: isLoading
              ? const Text('Loading...') // Show loading indicator
              : Text(widget.lastMessage),
          trailing: widget.readOrUnread
              ? Container(
                  width: 20,
                  height: 20,
                  color: Colors.red,
                )
              : const SizedBox(), // Display last message
        ),
      ),
    );
  }
}
