import 'dart:async';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tfg_app/src/config/config.dart';
import 'package:tfg_app/src/pages/init_page.dart';
import 'package:tfg_app/src/pages/authentication/select_authentication_page.dart';
import 'package:tfg_app/src/pages/authentication/register_page.dart';
import 'package:tfg_app/src/pages/authentication/login_page.dart';
import 'package:tfg_app/src/pages/admin_page.dart';
import 'package:tfg_app/src/pages/user_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SupermarketApp.auth = FirebaseAuth.instance;
  SupermarketApp.sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: SupermarketApp.appName,
        home: InitPage(),
        routes: {
          'authentication': (BuildContext context) => SelectAuthenticationPage(),
          'register': (BuildContext context) => RegisterPage(),
          'login': (BuildContext context) => LoginPage(),
          'adminPage': (BuildContext context) => AdminPage(),
          'userPage': (BuildContext context) => UserPage(),
        },
        theme: ThemeData(
            primaryColor: Colors.green, visualDensity: VisualDensity.adaptivePlatformDensity));
  }
}
