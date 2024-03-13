import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String sendId;
  final String recieveId;
  final String message;
  final DateTime sentTime;
  final bool isSend;
  bool isRead;

  Message({
    required this.message,
    required this.recieveId,
    required this.sendId,
    required this.sentTime,
    required this.isSend,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      recieveId: json['recieveId'],
      sendId: json['sendId'],
      sentTime: (json['sentTime'] as Timestamp).toDate(),
      isSend: json['isSend'],
      isRead: json['isRead'] ?? false,
    );
  }
  Map<String, dynamic> json() {
    return {
      'sendId': sendId,
      'recieveId': recieveId,
      'message': message,
      'sentTime': sentTime,
      'isSend': isSend,
      'isRead': isRead,
    };
  }
}
