import 'dart:developer';
import 'dart:io';

import 'package:chatapp/db/auth_db.dart';
import 'package:chatapp/model/message_model.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  List<UserModel> users = [];
  List<Message> messages = [];
  UserModel? appUser;
  UserModel? user;
  Map<String, Message> lastMessages =
      {}; // Map to store last message for each user
  Map<String, String> last = {}; // Map to store last message for each user

  ScrollController scrollController = ScrollController();
  final db = AuthDB();
  XFile? pickedImage;
  bool isloading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<List<UserModel>> getUsers() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .snapshots(includeMetadataChanges: true)
          .listen((event) {
        users = event.docs.map((e) => UserModel.fromJson(e.data())).toList();
        notifyListeners();
      });

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<UserCredential> sighInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      final currentUser = db.isCurrentUser();
      print(currentUser);
      if (currentUser != null) {
        appUser = await db.getUserById(uid: currentUser.uid);
      } else {
        log(currentUser.toString());
      }
      print(appUser);
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('error is${e.message}');
    }
  }

  Future<UserCredential> sighUpWithEmailAndPassword(
      UserModel user, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: user.email, password: password);
      appUser = user;
      await db.signUpUser(user: user, credential: userCredential);
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('error is${e.message}');
    }
  }

  Future<void> uploadProfileImage(XFile image) async {
    try {
      pickedImage = image;
      isloading = true;
      notifyListeners();
      if (pickedImage != null) {
        print('1');
        final url = await uploadImage(
            id: FirebaseAuth.instance.currentUser!.uid,
            file: pickedImage!,
            ref:
                "users/${FirebaseAuth.instance.currentUser!.uid}/${pickedImage!.name}");
        print('3');
        appUser?.image = url;
        updateUser(user: appUser!);
        print(url);
        print(appUser?.image);
        isloading = false;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(
      {required String id, required XFile file, required String ref}) async {
    try {
      log('2');
      final storage = FirebaseStorage.instance;
      TaskSnapshot taskSnapshot =
          await storage.ref(ref).putFile(File(file.path));
      log('here');
      final url = await taskSnapshot.ref.getDownloadURL();
      notifyListeners();

      return url;
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  void updateUser({required UserModel user}) async {
    await db.updateUser(user: user);
  }

  Future<User?> checkCurrentUser(BuildContext context) async {
    try {
      final isCurrentUser = db.isCurrentUser();
      if (isCurrentUser != null) {
        appUser = await db.getUserById(uid: isCurrentUser.uid);
        log(appUser!.toJson().toString());
        //notifyListeners();
        return isCurrentUser;
      }
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  UserModel? getUserById({required String uid}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots(includeMetadataChanges: true)
        .listen((data) {
      user = UserModel.fromJson(data.data()!);
      notifyListeners();
    });

    return user;
  }

  Future<void> sendMessge({
    required TextEditingController text,
    required String recieveId,
  }) async {
    final result = await initConnectivity();

    final message = Message(
        isSend: result ? true : false,
        message: text.text,
        recieveId: recieveId,
        sendId: FirebaseAuth.instance.currentUser!.uid,
        sentTime: DateTime.now());
    text.clear();
    log('1');
    await addMessageToDb(recieveId: recieveId, message: message);
  }

  Future<void> addMessageToDb({
    required String recieveId,
    required Message message,
  }) async {
    log(message.json().toString());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chats')
        .doc(recieveId)
        .collection('messages')
        .add(message.json());
    log('2');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(recieveId)
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .add(message.json());
    log('3');
  }

  Future<void> deleteMessages({required String receiverId}) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      notifyListeners();
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }

  Future<List<Message>> getAllMessages({required String recieverId}) async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chats')
          .doc(recieverId)
          .collection('messages')
          .orderBy('sentTime', descending: false)
          .snapshots(includeMetadataChanges: true)
          .listen((event) {
        // messages = event.docs.map((e) => Message.fromJson(e.data())).toList();
        messages = event.docs.map((e) {
          Message message = Message.fromJson(e.data());
          // Mark the message as read when it's fetched
          message.isRead = true;
          return message;
        }).toList();
        if (messages.isNotEmpty) {
          // Determine the last message for this receiver
          Message lastMessage = messages.last;
          String recievedId = recieverId; // Store receiverId

          // Update last message for this receiver

          lastMessages[recievedId] = lastMessage;
          last[recievedId] = lastMessage.message;
        } else {
          // No messages
          String recievedId = recieverId; // Store receiverId

          lastMessages[recievedId] = Message(
              message: '',
              recieveId: '',
              sendId: '',
              sentTime: DateTime.now(),
              isSend: true); // Empty string if no messages
        }

        scrollToEnd();
        notifyListeners();
      });

      log('khaaaa${messages.toString()}');

      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow; // You can handle the error as needed in the calling code
    }
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> updateUserStatus(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(data);
  }

  Future<void> saveToken({required String token}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  Future<bool> initConnectivity() async {
    bool isConnected = false;
    ConnectivityResult connectivityResult = ConnectivityResult.none;
    try {
      connectivityResult = await connectivity.checkConnectivity();
    } catch (e) {
      print('Error: $e');
    }
    connectionStatus = connectivityResult;
    if (connectionStatus == ConnectivityResult.mobile ||
        connectionStatus == ConnectivityResult.wifi) {
      isConnected = true;
    }
    notifyListeners();
    return isConnected;
  }
}
