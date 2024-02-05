import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/widgets/single_user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  void getAllUsers() {
    context.read<AuthController>().getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        title: const Text('Chat Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Consumer<AuthController>(
              builder: (context, value, child) {
                return value.isloading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(
                        children: [
                          value.appUser?.image != null
                              ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(value.appUser!.image!),
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                ),
                          Positioned(
                              bottom: 0,
                              right: 10,
                              child: GestureDetector(
                                  onTap: () async {
                                    final img = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);

                                    if (img != null) {
                                      await value.uploadProfileImage(img);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.camera,
                                    color: Colors.deepOrange,
                                  )))
                        ],
                      );
              },
            ),
            Consumer<AuthController>(
              builder: (context, value, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: value.users.length,
                    itemBuilder: (context, index) {
                      return SingleUser(
                        user: value.users[index],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
