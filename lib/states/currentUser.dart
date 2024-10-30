import 'package:book_club/models/user.dart';
import 'package:book_club/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CurrentUser extends ChangeNotifier {
  OurUser? _currentUser;
  OurUser? get getCurrentUser => _currentUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Automatically checks if a user is logged in when app starts
  Future<String> onStartUp() async {
    String retValue = "error";
    try {
      User? firebaseUser = _auth.currentUser;

      if (firebaseUser != null) {
        _currentUser = await OurDatabase().getUserInfo(firebaseUser.uid);
        if (_currentUser != null) {
          retValue = "success";
        }
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Startup Error: $e");
    }
    return retValue;
  }

  // Checks if the user is an admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Logs out the current user
  Future<String> signOut() async {
    String retValue = "error";
    try {
      await _auth.signOut();
      _currentUser = null; // Clear current user data
      retValue = "success";
    } catch (e) {
      print("Sign-out Error: $e");
    }
    return retValue;
  }

  // Signs up a new user with email and password
  Future<String> signUpUser(
      String email, String password, String fullName) async {
    String retVal = "error";

    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (authResult.user != null) {
        OurUser user = OurUser(
          uid: authResult.user!.uid,
          email: authResult.user!.email!,
          fullName: fullName,
          accountCreated: Timestamp.now(),
        );

        String returnString = await OurDatabase().createUser(user);

        if (returnString == "success") {
          retVal = "success";
        }
      }
    } on FirebaseException catch (e) {
      retVal = e.message!;
    } catch (e) {
      print("Sign-up Error: $e");
    }

    return retVal;
  }

  // Logs in user with email and password
  Future<String> loginUserWithEmail(String email, String password) async {
    String retVal = "error";
    try {
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = authResult.user;
      if (user != null) {
        // Fetch user info from Firestore
        _currentUser = await OurDatabase().getUserInfo(user.uid);

        // Check if user is an admin
        bool isAdmin = _currentUser?.isAdmin ?? false;
        retVal = isAdmin ? "admin" : "success";
      }
    } catch (e) {
      print("Login Error: Invalid Credentials or $e");
      retVal = "Invalid Credentials";
    }
    return retVal;
  }

  // Logs in user with Google account
  Future<String> loginUserWithGoogle() async {
    String retVal = "error";
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],

      clientId:
          "939481362724-pbk7511uc039g26l6qip3o79fpbi5k9s.apps.googleusercontent.com", // Replace with actual client ID
    );

    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return "cancelled";
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      if (user != null) {
        String uid = user.uid;
        String email = user.email!;

        _currentUser = await OurDatabase().getUserInfo(uid);
        retVal = _currentUser != null ? "success" : "error";
      }
    } catch (e) {
      print("Google Login Error: $e");
      retVal = "failed";
    }

    return retVal;
  }
}
