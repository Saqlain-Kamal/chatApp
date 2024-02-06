class Message {
  final String sendId;
  final String recieveId;
  final String messge;
  final DateTime sentTime;

  Message({
    required this.messge,
    required this.recieveId,
    required this.sendId,
    required this.sentTime,
  });
}
