import 'package:cloud_firestore/cloud_firestore.dart';

class OurUser {
  String uid;
  String email;
  String? fullName;
  Timestamp accountCreated;

  bool isAdmin; // New field to store admin status

  OurUser({
    required this.uid,
    required this.email,
    this.fullName,
    required this.accountCreated,
    this.isAdmin = false, // Default to false for non-admins
  });
}
