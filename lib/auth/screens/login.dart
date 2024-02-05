import 'package:chatapp/auth/screens/sign_up.dart';
import 'package:chatapp/auth/widgets/text_fields.dart';
import 'package:chatapp/common/custom_button.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Icon(
                Icons.lock,
                size: 150,
              ),
              Column(
                children: [
                  TextFieldWidget(
                      controller: emailController, hint: 'Enter Name'),
                  const SizedBox(
                    height: 40,
                  ),
                  TextFieldWidget(
                    controller: passwordController,
                    hint: 'Enter password',
                  ),
                ],
              ),
              Column(
                children: [
                  CustomButton(
                    text: 'Log In',
                    isloading: isloading,
                    onTap: () async {
                      setState(() {
                        isloading = true;
                      });
                      try {
                        await context
                            .read<AuthController>()
                            .sighInWithEmailAndPassword(
                                emailController.text.trim(),
                                passwordController.text.trim());
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatScreen()));
                      } catch (e) {
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
                                builder: (context) => const SignUpScreen()));
                      },
                      child: const Text(
                        'SignUp',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
