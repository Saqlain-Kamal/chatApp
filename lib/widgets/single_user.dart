import 'package:chatapp/model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleUser extends StatelessWidget {
  const SingleUser({super.key, required this.user});
  final UserModel user;
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.Hm().format(user.lastSeen);
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.image!),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(50)),
              width: 12,
              height: 12,
            ),
          )
        ],
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Text(formattedDate),
    );
  }
}
