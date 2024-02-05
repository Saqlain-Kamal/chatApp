import 'dart:developer';
import 'dart:io';

import 'package:chatapp/db/auth_db.dart';
import 'package:chatapp/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  List<UserModel> users = [];
  UserModel? appUser;
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
}
