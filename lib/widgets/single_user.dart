import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/common/media_query.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:chatapp/screens/individual_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleUser extends StatefulWidget {
  const SingleUser({super.key, required this.user});
  final UserModel user;

  @override
  State<SingleUser> createState() => _SingleUserState();
}

class _SingleUserState extends State<SingleUser> {
  @override
  Widget build(BuildContext context) {
    print(widget.user.image);
    String formattedDate = DateFormat.Hm().format(widget.user.lastSeen);
    return GestureDetector(
      onTap: () {
        print(widget.user.name);
        print('object');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => IndividualChatScreen(
                      user: widget.user,
                    )));
      },
      child: ListTile(
        leading: Stack(
          children: [
            widget.user.image != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange.shade100,
                    child:
                        // CachedNetworkImage(
                        //   placeholder: (context, url) =>
                        //       const CircularProgressIndicator(
                        //     strokeWidth: 1,
                        //     color: Colors.deepOrange,
                        //   ),
                        //   imageUrl: user.image!,
                        // ),
                        Container(
                            height: screenHeight(context),
                            width: screenWidth(context),
                            // margin: EdgeInsets.all(5),
                            // padding: EdgeInsets.all(5),
                            clipBehavior: Clip.antiAlias,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image!,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.deepOrange,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            )),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.orange.shade100,
                  ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(50)),
                width: 12,
                height: 12,
              ),
            )
          ],
        ),
        title: Text(widget.user.name),
        subtitle: Text(widget.user.email),
        trailing: Text(formattedDate),
      ),
    );
  }
}
