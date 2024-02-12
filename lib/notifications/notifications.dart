import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/controller/auth_controller.dart';
import 'package:chatapp/screens/individual_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NotificationServices {
  static const String key =
      'AAAA42QXzLk:APA91bEPL6Sw0QdZiyW0cd2aw4BK36BRxkSx6ZlHB7FW0xH7quociA0oOKMKDqx9BTwXuTr8KcbMB1X5g-9bbdKiDpUEDpOtN8mnMCk8Hh80MvpWMlxvIAHurknpySEY0efJroatvodb';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification() {
    const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint(details.payload.toString());
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title,
        htmlFormatTitle: true);
    final androidDetails = AndroidNotificationDetails(
      'com.example.chatapp',
      'mychannelid',
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: styleInformation,
    );
    const iosDetail =
        DarwinNotificationDetails(presentAlert: true, presentBadge: true);
    final notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetail);

    await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
        message.notification!.body, notificationDetails,
        payload: message.data['body']);
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      sound: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      alert: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User Granted Provisional Permission');
    } else {
      debugPrint('User decline');
    }
  }

  Future<void> getToken(BuildContext context) async {
    final token = FirebaseMessaging.instance.getToken().toString();
    log('device Token is$token');

    await context.read<AuthController>().saveToken(token: token);
  }

  String recieverToken = '';
  Future<void> getRecieverToken(String receiverId) async {
    final getToken = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    recieverToken = getToken.data()!['token'];
  }

  Future<void> sendNotification(
      {required String body, required String sendId}) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$key'
          },
          body: jsonEncode({
            'to': recieverToken,
            'priority': 'high',
            'notification': {
              'body': body,
              'title': 'new Message !',
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'senderId': sendId,
            }
          }));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void firebaseNotification(context) {
    initLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IndividualChatScreen(
            userId: message.data['senderId'],
          ),
        ),
      );
    });
    FirebaseMessaging.onMessage.listen((message) async {
      await showNotification(message);
    });
  }
}
