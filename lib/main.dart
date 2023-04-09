import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wsa/homePage.dart';
import 'package:wsa/profilePage.dart';

import 'authPage.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
    runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bluetooth Demo',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

