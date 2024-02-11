class UserModel {
  final String name;
  final String email;
  String? image;
  String uid;
  final DateTime lastSeen;
  final bool isOnline;
  final bool isTyping;

  UserModel({
    required this.email,
    this.image,
    required this.isOnline,
    required this.lastSeen,
    required this.name,
    required this.uid,
    required this.isTyping,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'],
        image: json['image'],
        isOnline: json['isOnline'],
        lastSeen: json['lastSeen'].toDate(),
        name: json['name'],
        uid: json['uid'],
        isTyping: json['isTyping']);
  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'uid': uid,
      'image': image,
      'isTyping': isTyping,
    };
  }
}
