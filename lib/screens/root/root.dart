import 'package:book_club/screens/Admin/AdminHome.dart';
import 'package:book_club/screens/home/home.dart';
import 'package:book_club/screens/login/login.dart';
import 'package:book_club/screens/User/HomePage.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OurRoot extends StatefulWidget {
  const OurRoot({super.key});

  @override
  State<OurRoot> createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  bool isLoggedIn = false; // For checking if the user is logged in
  bool isAdmin = false; // For checking if the user is an admin

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    String returnString = await currentUser.onStartUp();

    if (returnString == "success") {
      setState(() {
        isLoggedIn = true; // User is logged in
        isAdmin = currentUser.isAdmin; // Check if user is admin
      });
    } else {
      setState(() {
        isLoggedIn = false; // User is not logged in
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return OurLogin();
    }

    // Return different pages based on user role
    return isAdmin
        ? AdminHomePage()
        : HomePage(); // Use an AdminHomePage for admin users
  }
}
