import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cast the result to int after the fold operation
    int totalAmount = cartItems.fold(
        0, (int sum, item) => sum + (item['price'] * item['quantity']) as int);

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                          "Price: \$${item['price']} x ${item['quantity']}"),
                      trailing:
                          Text("Total: \$${item['price'] * item['quantity']}"),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              "Total Price: \$$totalAmount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showPaymentOptions(context, totalAmount);
              },
              child: Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, int totalAmount) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return PaymentOptions(
          cartItems: cartItems,
          totalAmount: totalAmount,
        );
      },
    );
  }
}

class PaymentOptions extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final int totalAmount;

  const PaymentOptions({Key? key, required this.cartItems, required this.totalAmount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text("Credit/Debit Card"),
            onTap: () => _placeOrder(context, "Credit/Debit Card"),
          ),
          ListTile(
            leading: Icon(Icons.money),
            title: Text("Cash on Delivery"),
            onTap: () => _placeOrder(context, "Cash on Delivery"),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, String paymentMethod) async {
    CollectionReference orders =
        FirebaseFirestore.instance.collection('orders');

    await orders.add({
      'items': cartItems
          .map((item) => {
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
                'total': item['price'] * item['quantity'],
              })
          .toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': "placed",
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );
  }
}
