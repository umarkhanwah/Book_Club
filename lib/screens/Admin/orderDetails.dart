import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagementPage extends StatelessWidget {
  final List<String> orderStatuses = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
  ];

  OrderManagementPage({Key? key}) : super(key: key);

  void updateOrderStatus(String orderId, String status, String userId) async {
    // Update order status
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'orderStatus': status});

    // Add a notification
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'message': 'Your order status has been $status',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Orders Found"));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final paymentStatus = order['paymentStatus'];
              final paymentMethod = order['paymentMethod'];
              final orderStatus = order[
                  'orderStatus']; // Assuming 'orderStatus' is the correct field name
              final userId = order[
                  'userId']; // Assuming 'userId' is stored in the order document

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ExpansionTile(
                  title: Text("Order ID: ${order.id}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total: \$${order['totalAmount']}"),
                      Text("Payment Method: $paymentMethod"),
                      Text("Payment Status: $paymentStatus"),
                      Row(
                        children: [
                          Text("Order Status: "),
                          DropdownButton<String>(
                            value: orderStatus,
                            onChanged: (newStatus) {
                              if (newStatus != null) {
                                updateOrderStatus(order.id, newStatus, userId);
                              }
                            },
                            items: orderStatuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  children: items.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text("Author: ${item['author']}"),
                      trailing: Text(
                          "Price: \$${item['price']} x ${item['quantity']}"),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
