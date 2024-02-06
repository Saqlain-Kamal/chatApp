import 'package:chatapp/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthDB {
  Future<void> signUpUser(
      {required UserModel user, required UserCredential credential}) async {
    try {
      print('i am here');
      user.uid = credential.user!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser({required UserModel user}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(user.toJson());
  }

  Future<UserModel?> getUserById({required String uid}) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = snapshot.data();
    return UserModel.fromJson(data!);
  }

  User? isCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
