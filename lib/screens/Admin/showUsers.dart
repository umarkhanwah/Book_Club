import 'package:book_club/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowUsers extends StatefulWidget {
  const ShowUsers({super.key});

  @override
  State<ShowUsers> createState() => _ShowUsersState();
}

class _ShowUsersState extends State<ShowUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Users Found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userModel = OurUser(
                uid: user.id,
                fullName: user['fullName'],
                email: user['email'],
                isAdmin: user['isAdmin'] ?? false,
                accountCreated: user['accountCreated'],
              );

              return ListTile(
                hoverColor: Colors.lightGreen[100],
                title: Text(userModel.fullName!),
                subtitle: Text(userModel.email),
                trailing: userModel.isAdmin
                    ? Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.green),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: () => _makeAdmin(userModel),
                        child: Text("Make Admin"),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _makeAdmin(OurUser user) async {
    // Update the user's isAdmin status in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'isAdmin': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${user.fullName} has been made an admin")),
    );
  }
}
