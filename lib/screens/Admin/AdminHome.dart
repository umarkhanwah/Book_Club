import 'package:book_club/screens/Admin/addBook.dart';
import 'package:book_club/screens/Admin/orderDetails.dart';
import 'package:book_club/screens/Admin/showCategories.dart';

import 'package:book_club/screens/Admin/showProduct.dart';
import 'package:book_club/screens/Admin/showUsers.dart';
import 'package:book_club/screens/root/root.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  void _signOut(BuildContext context) async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    String returnString = await currentUser.signOut();
    if (returnString == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OurRoot(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Add SingleChildScrollView for overflow handling
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap:
                true, // Allow the GridView to take only the space it needs
            physics:
                NeverScrollableScrollPhysics(), // Disable scrolling in GridView
            children: <Widget>[
              _buildDashboardCard("Orders", "5", Icons.list, Colors.blue,
                  onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderManagementPage()));
              }),
              _buildDashboardCard("Users", "120", Icons.people, Colors.green,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShowUsers()));
              }),
              _buildDashboardCard("Products", "30", Icons.book, Colors.orange,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShowProducts()));
              }),
              _buildDashboardCard("Add Books", "", Icons.add, Colors.purple,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddBook()));
              }),
              _buildDashboardCard("Categories", "", Icons.category, Colors.teal,
                  onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShowCategories()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, String count, IconData icon, Color color,
      {Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 45, color: Colors.white),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
