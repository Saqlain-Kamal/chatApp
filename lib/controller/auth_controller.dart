import 'package:chatapp/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  List<UserModel> users = [];
  UserModel? appUser;

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
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('error is${e.message}');
    }
  }
}
