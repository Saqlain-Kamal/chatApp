import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/widgets/single_user.dart';
import 'package:flutter/material.dart';
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
        title: const Text('Chat Screen'),
      ),
      body: Consumer<AuthController>(
        builder: (context, value, child) {
          return ListView.builder(
            itemCount: value.users.length,
            itemBuilder: (context, index) {
              return SingleUser(
                user: value.users[index],
              );
            },
          );
        },
      ),
    );
  }
}
