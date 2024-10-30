import 'package:book_club/screens/User/Shop.dart';
import 'package:book_club/screens/User/review.dart';
import 'package:book_club/screens/home/home.dart';
import 'package:book_club/screens/login/login.dart';
import 'package:book_club/services/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomePage({Key? key}) : super(key: key);

  Future<bool> _hasDeliveredOrders() async {
    final User user = _auth.currentUser!;
    final userId = user.uid;

    final orders = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('orderStatus', isEqualTo: 'Delivered')
        .get();

    return orders.docs.isNotEmpty;
  }

  void _goToShop(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ShopPage()));
  }

  void _goToCreate(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void _logout(BuildContext context) async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    String returnString = await currentUser.signOut();

    if (returnString == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OurLogin()),
        (route) => false,
      );
    } else {
      print("Logout failed: $returnString");
    }
  }

  void _showNotifications(BuildContext context) async {
    final deliveredOrders = await _hasDeliveredOrders();

    // Retrieve and sort notifications by timestamp in descending order
    final notifications =
        Provider.of<NotificationProvider>(context, listen: false).notifications
          ..sort((a, b) => b.body.compareTo(a.body)); // Sorting by timestamp

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Notifications"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.body),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<NotificationProvider>(context,
                                  listen: false)
                              .removeNotification(notification.id);
                        },
                      ),
                    );
                  },
                ),
                if (deliveredOrders)
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _goToReviewForm(context);
                    },
                    icon: Icon(Icons.rate_review_rounded),
                    color: Colors.green,
                    iconSize: 32.0,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _goToReviewForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    return Stack(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 30,
                          ),
                          onPressed: () {
                            _showNotifications(context);
                          },
                        ),
                        if (notificationProvider.notificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '${notificationProvider.notificationCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.person,
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  onSelected: (value) {
                    if (value == "User Info") {
                      print("User Info selected");
                    } else if (value == "Logout") {
                      _logout(context);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {'User Info', 'Logout'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          Spacer(flex: 1),
          Padding(
            padding: EdgeInsets.all(80.0),
            child: Image.asset("assets/logo.png"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Welcome to Book Club",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "We Offer Best Comic, Novel & Study Books",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _goToShop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).canvasColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor,
                        width: 2,
                      ),
                    ),
                    foregroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                  child: Text(
                    "Books Store",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  child: Text(
                    "Read",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _goToShop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
