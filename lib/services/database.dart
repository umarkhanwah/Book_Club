import 'package:book_club/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OurDatabase {
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUser(OurUser user) async {
    String retVal = "error";

    try {
      await _firestore.collection("users").doc(user.uid).set({
        'fullName': user.fullName,
        'email': user.email,
        'accountCreated': Timestamp.now(),
        'isAdmin': user.isAdmin, // Add isAdmin if applicable
      });
      retVal = "success";
    } catch (e) {
      print("Error creating user: $e");
    }

    return retVal;
  }

  Future<OurUser?> getUserInfo(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      if (doc.exists) {
        return OurUser(
          uid: uid,
          email: doc["email"],
          fullName: doc["fullName"],
          accountCreated: doc["accountCreated"],

          isAdmin: doc["isAdmin"] ?? false, // Retrieve isAdmin status
        );
      }
      return null;
    } catch (e) {
      print("Error getting user info: $e");
      return null;
    }
  }

  // Future<String> createGroup(String groupName, String userUid) async {
  //   String retVal = "error";
  //   List<String> members = [];

  //   try {
  //     members.add(userUid);
  //     DocumentReference _docRef = await _firestore.collection("groups").add({
  //       'name': groupName,
  //       'leader': userUid,
  //       'members': members,
  //       'groupCreate': Timestamp.now(),
  //     });

  //     await _firestore.collection("users").doc(userUid).update({
  //       'groupId': _docRef.id,
  //     });

  //     retVal = "success";
  //   } catch (e) {
  //     print(e);
  //   }

  //   return retVal;
  // }

  // Future<String> joinGroup(String groupId, String userUid) async {
  //   String retVal = "error";
  //   List<String> members = [];

  //   try {
  //     members.add(userUid);
  //     await _firestore.collection("groups").doc(groupId).update({
  //       'members': FieldValue.arrayUnion(members),
  //     });
  //     await _firestore.collection("users").doc(userUid).update({
  //       'groupId': groupId,
  //     });

  //     retVal = "success";
  //   } on PlatformException catch (e) {
  //     retVal = "Make sure you have the right group ID!";
  //   } catch (e) {
  //     print(e);
  //   }

  //   return retVal;
  // }

  // Future<OurGroup> getGroupInfo(String groupId) async {
  //   if (groupId == null || groupId.isEmpty) {
  //     throw Exception("Invalid groupId");
  //   }

  //   DocumentSnapshot doc =
  //       await _firestore.collection('groups').doc(groupId).get();
  //   if (doc.exists) {
  //     return OurGroup.fromDocumentSnapshot(doc);
  //   } else {
  //     throw Exception("Group not found");
  //   }
  // }
}
