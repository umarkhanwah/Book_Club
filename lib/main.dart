import 'package:book_club/screens/root/root.dart';
import 'package:book_club/services/notification_provider.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:book_club/utils/ourTheme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDtmL5HfKcBu71hPxD26kF5yGFq8xn9-sw",
        authDomain: "bookclub-5b239.firebaseapp.com",
        projectId: "bookclub-5b239",
        storageBucket: "bookclub-5b239.appspot.com",
        messagingSenderId: "939481362724",
        appId: "1:939481362724:web:6ffb722678d856741c43b1",
        measurementId: "G-MSFYTYESCH"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CurrentUser()),
        ChangeNotifierProvider(
            create: (context) =>
                NotificationProvider()), // Add NotificationProvider here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: OurTheme().buildTheme(),
        home: OurRoot(),
      ),
    );
  }
}
