import 'dart:developer';
import 'dart:io';

import 'package:chatapp/db/auth_db.dart';
import 'package:chatapp/model/message_model.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  List<UserModel> users = [];
  List<Message> messages = [];
  UserModel? appUser;
  UserModel? user;

  final db = AuthDB();
  XFile? pickedImage;
  bool isloading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  List<UserModel> getUsers() {
    FirebaseFirestore.instance
        .collection('users')
        .snapshots(includeMetadataChanges: true)
        .listen((user) {
      users = user.docs.map((e) => UserModel.fromJson(e.data())).toList();
      notifyListeners();
    });

    return users;
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
    required String text,
    required String recieveId,
  }) async {
    final message = Message(
        message: text,
        recieveId: recieveId,
        sendId: FirebaseAuth.instance.currentUser!.uid,
        sentTime: DateTime.now());

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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(recieveId)
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('messages')
        .add(message.json());
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
        messages = event.docs.map((e) => Message.fromJson(e.data())).toList();
        notifyListeners();
      });

      log('khaaaa${messages.toString()}');

      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      rethrow; // You can handle the error as needed in the calling code
    }
  }
}
