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
    final screenWidth = MediaQuery.of(context).size.width;
    final messageWidth = MediaQuery.of(context).size.width / 1.5;
    return Align(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: isMe
            ? const EdgeInsets.only(right: 10, top: 10, bottom: 10, left: 100)
            : const EdgeInsets.only(right: 100, top: 10, bottom: 10, left: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: isMe
              ? LinearGradient(
                  colors: [Colors.orange.shade600, Colors.orange.shade400],
                )
              : LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade100],
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                  fontSize: 15, color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm').format(message.sentTime),
                ),
                isMe
                    ? message.isSend
                        ? const Icon(
                            Icons.done,
                            size: 20,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.punch_clock,
                            size: 20,
                            color: Colors.white,
                          )
                    : const SizedBox()
              ],
            )
          ],
        ),
      ),
    );
  }
}
