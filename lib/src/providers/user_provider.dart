import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:tfg_app/src/config/config.dart';
import 'package:tfg_app/src/dialog/display_dialog.dart';

class UserProvider {
  static final _auth = SupermarketApp.auth;
  final userDatabaseReference = FirebaseDatabase.instance.reference().child('usuarios');

  Future<void> register(BuildContext context, User user, String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((auth) {
      user = auth.user;
    }).catchError((onError) {
      DisplayDialog.displayErrorDialog(context, onError.message.toString());
    });

    if (user != null) {
      await _saveUserInfo(user).then((value) {
        Navigator.pushReplacementNamed(context, 'userPage');
      });
    }
  }

  Future<void> login(BuildContext context, User user, String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password).then((auth) {
      user = auth.user;
    }).catchError((onError) {
      DisplayDialog.displayErrorDialog(context, onError.message.toString());
    });
    if (user != null) {
      await getUserInfo(context, user);
    }
  }

  Future<void> logOut(BuildContext context) async {
    await SupermarketApp.auth.signOut().then((value) async {
      await _deleteSessionInfo();
      Navigator.pushReplacementNamed(context, 'authentication');
    });
  }

  Future _saveUserInfo(User newUser) async {
    userDatabaseReference.child('clientes').child(newUser.uid).set({
      'uid': newUser.uid,
      'email': newUser.email,
      SupermarketApp.userCartList: ['garbageValue']
    });

    await SupermarketApp.sharedPreferences.setString('uid', newUser.uid);
    await SupermarketApp.sharedPreferences.setString(SupermarketApp.userEmail, newUser.email);
    await SupermarketApp.sharedPreferences
        .setStringList(SupermarketApp.userCartList, ['garbageValue']);
  }

  Future getUserInfo(BuildContext context, User user) async {
    userDatabaseReference
        .child('clientes')
        .child(user.uid)
        .once()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        await SupermarketApp.sharedPreferences
            .setString('uid', snapshot.value[SupermarketApp.userUID]);
        await SupermarketApp.sharedPreferences
            .setString(SupermarketApp.userEmail, snapshot.value[SupermarketApp.userEmail]);

        List<String> _cartList = snapshot.value[SupermarketApp.userCartList].cast<String>();
        await SupermarketApp.sharedPreferences
            .setStringList(SupermarketApp.userCartList, _cartList);

        Navigator.pushReplacementNamed(context, 'userPage');
      } else {
        userDatabaseReference
            .child('admins')
            .child(user.uid)
            .once()
            .then((DataSnapshot snapshot) async {
          if (snapshot.value != null) {
            await SupermarketApp.sharedPreferences
                .setString('uid', snapshot.value[SupermarketApp.userUID]);
            await SupermarketApp.sharedPreferences
                .setString(SupermarketApp.userEmail, snapshot.value[SupermarketApp.userEmail]);

            Navigator.pushReplacementNamed(context, 'adminPage');
          } else {
            DisplayDialog.displayErrorDialog(context, 'Los datos no son validos');
          }
        });
      }
    });
  }

  Future _deleteSessionInfo() async {
    await SupermarketApp.sharedPreferences.setString('uid', 'uid');
    await SupermarketApp.sharedPreferences.setString(SupermarketApp.userEmail, 'email');
    await SupermarketApp.sharedPreferences.setStringList(SupermarketApp.userCartList, ['userCart']);
  }

  Future<bool> isAdminLooged() async {
    bool admin = false;
    await userDatabaseReference
        .child('admins')
        .child(SupermarketApp.auth.currentUser.uid)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        admin = true;
      }
    });
    return admin;
  }
}
