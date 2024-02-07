import 'package:chatapp/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessgeBubble extends StatelessWidget {
  const MessgeBubble({
    required this.message,
    required this.isMe,
    super.key,
  });
  final Message message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isMe ? Colors.orange.shade400 : Colors.blue.shade400),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            SizedBox(
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
            Text(DateFormat.Hms().format(message.sentTime))
          ],
        ),
      ),
    );
  }
}
