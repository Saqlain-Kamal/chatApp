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
          gradient: isMe
              ? LinearGradient(
                  colors: [Colors.orange.shade500, Colors.orange.shade400],
                )
              : LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade100],
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SizedBox(
              child: Text(
                message.message,
                style: TextStyle(
                    fontSize: 15, color: isMe ? Colors.white : Colors.black),
              ),
            ),
            Text(DateFormat('h:mm').format(message.sentTime))
          ],
        ),
      ),
    );
  }
}
