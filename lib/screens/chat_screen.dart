import 'package:chatapp/auth/screens/login.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/notifications/notifications.dart';
import 'package:chatapp/widgets/single_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final notification = NotificationServices();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getAllUsers();

    notification.firebaseNotification(context);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('my state is${state.name}');
    switch (state) {
      case AppLifecycleState.resumed:
        context.read<AuthController>().updateUserStatus({'isOnline': true});

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        context.read<AuthController>().updateUserStatus({
          'isOnline': false,
          'lastSeen': DateTime.now(),
        });

      default:
    }
    super.didChangeAppLifecycleState(state);
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
                onTap: () async {
                  print('object');
                  await FirebaseAuth.instance.signOut().then((value) {
                    return Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false);
                  });
                },
                child: const Icon(Icons.logout)),
          ),
        ],
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
                                try {
                                  final img = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);

                                  if (img != null) {
                                    await value.uploadProfileImage(img);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Colors.deepOrange,
                                    content: Text(
                                      e.toString(),
                                    ),
                                  ));
                                }
                              },
                              child: const Icon(
                                Icons.camera,
                                color: Colors.deepOrange,
                              ),
                            ),
                          )
                        ],
                      );
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Consumer<AuthController>(
              builder: (context, value, child) {
                return Expanded(
                  child: value.users.isEmpty ||
                          (value.users.length == 1 &&
                              value.users.first.uid ==
                                  FirebaseAuth.instance.currentUser!.uid)
                      ? const Center(
                          child: Text('No Users'),
                        )
                      : ListView.builder(
                          itemCount: value.users.length,
                          itemBuilder: (context, index) {
                            return value.users[index].uid !=
                                    FirebaseAuth.instance.currentUser!.uid
                                ? SingleUser(
                                    user: value.users[index],
                                    lastMessage: value
                                        .lastMessages[value.users[index].uid]
                                        .toString(),
                                  )
                                : const SizedBox();
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
