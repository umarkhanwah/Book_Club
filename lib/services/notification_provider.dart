import 'package:book_club/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get notificationCount => _notifications.length;

  NotificationProvider() {
    fetchNotifications();
  }

  void fetchNotifications() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('notifications').get();
    _notifications = snapshot.docs
        .map((doc) => NotificationModel(
              id: doc.id,
              title: doc['message'],
              body: doc['timestamp'].toDate().toString(),
            ))
        .toList();
    notifyListeners();
  }

  void removeNotification(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .delete();
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
}
