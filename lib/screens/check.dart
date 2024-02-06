import 'package:chatapp/auth/screens/login.dart';
import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  @override
  void initState() {
    load();
    super.initState();
  }

  Future<void> load() async {
    Future.delayed(
        const Duration(
          seconds: 2,
        ), () async {
      final isCurrentUser =
          await context.read<AuthController>().checkCurrentUser(context);
      if (isCurrentUser != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ChatScreen()));
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      ),
    );
  }
}
