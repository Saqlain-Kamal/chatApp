import 'dart:io';

import 'package:chatapp/auth/screens/login.dart';
import 'package:chatapp/auth/widgets/text_fields.dart';
import 'package:chatapp/common/custom_button.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:chatapp/notifications/notifications.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final notification = NotificationServices();
  bool isloading = false;
  File? selected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenHeight(context) * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 150,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFieldWidget(
                          controller: emailController, hint: 'Enter Email'),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                        controller: passwordController,
                        hint: 'Enter password',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFieldWidget(
                        controller: nameController,
                        hint: 'Enter Name',
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomButton(
                        text: 'Sign Up',
                        isloading: isloading,
                        onTap: () async {
                          setState(() {
                            isloading = true;
                          });
                          try {
                            DateTime now = DateTime.now();
                            String formattedDate =
                                DateFormat.yMMMEd().format(now);
                            print(formattedDate);
                            final user = UserModel(
                                isTyping: false,
                                email: emailController.text.trim(),
                                isOnline: true,
                                lastSeen: now,
                                name: nameController.text.trim(),
                                uid: '');
                            await context
                                .read<AuthController>()
                                .sighUpWithEmailAndPassword(
                                  user,
                                  passwordController.text.trim(),
                                );
                            await notification.requestPermission();
                            // ignore: use_build_context_synchronously
                            await notification.getToken(context);

                            print('1');

                            print('2'); // ignore:
                            // use_build_context_synchronously
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatScreen()));
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.deepOrange,
                              content: Text(
                                e.toString(),
                              ),
                            ));
                          }
                          setState(() {
                            isloading = false;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()));
                            },
                            child: const Text(
                              'Login',
                              textAlign: TextAlign.end,
                            ),
                          )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<XFile?> pickImage({required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    final img = await picker.pickImage(source: imageSource);
    return img;
  }
}
