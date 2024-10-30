import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    return cartSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<void> _showCartConfirmation(BuildContext context) async {
    final cartItems = await _fetchCartItems();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Your cart is empty!")));
      return;
    }

    // Calculate total amount
    final totalAmount = cartItems.fold(
        0, (int sum, item) => sum + (item['price'] * item['quantity']) as int);

    // Show first bottom sheet with cart details and total amount
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take up more screen space
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirm Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...cartItems.map((item) {
                  return ListTile(
                    title: Text(item['name']),
                    subtitle:
                        Text("Price: \$${item['price']} x ${item['quantity']}"),
                    trailing: Text("\$${item['price'] * item['quantity']}"),
                  );
                }),
                Divider(),
                ListTile(
                  title: Text("Total Amount",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text("\$$totalAmount",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the first bottom sheet
                    _showPaymentMethodSelection(context, totalAmount);
                  },
                  child: Text("Confirm Order"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPaymentMethodSelection(
      BuildContext context, int totalAmount) async {
    // Show second bottom sheet for payment method selection
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text("Stripe"),
                onTap: () async {
                  await _submitOrder(context, "Stripe", totalAmount);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet),
                title: Text("PayPal"),
                onTap: () async {
                  await _submitOrder(context, "PayPal", totalAmount);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.money),
                title: Text("Cash on Delivery"),
                onTap: () async {
                  await _submitOrder(context, "COD", totalAmount);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitOrder(
      BuildContext context, String paymentMethod, int totalAmount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final cartItems = await _fetchCartItems();
    try {
      // Create an order document with cart items, metadata, payment method, total amount, and default order status
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        'items': cartItems.map((item) {
          return {
            'name': item['name'],
            'author': item['author'],
            'price': item['price'],
            'quantity': item['quantity'],
            'imageUrl': item['imageUrl'],
          };
        }).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == "COD" ? "Pending" : "Paid",
        'orderStatus':
            'Pending', // Ensure orderStatus is added with a default value
      });

      // Clear the cart
      final batch = FirebaseFirestore.instance.batch();
      for (var item in cartItems) {
        final cartItemRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(item['id']);
        batch.delete(cartItemRef);
      }
      await batch.commit();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Order placed successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order. Please try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your cart is empty."));
          }

          final cartItems = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Author: ${item['author']}"),
                            Text("Price: \$${item['price']}"),
                            Text("Quantity: ${item['quantity']}"),
                          ],
                        ),
                        leading: item['imageUrl'] != null &&
                                item['imageUrl'].isNotEmpty
                            ? Image.network(
                                item['imageUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              )
                            : Icon(Icons.book, size: 50),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .collection('cart')
                                .doc(item['id'])
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Item removed from cart")));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showCartConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Checkout"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchWishlistItems() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final wishlistSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .get();

    return wishlistSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Wishlist"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchWishlistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Your wishlist is empty."));
          }

          final wishlistItems = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistItems[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Author: ${item['author']}"),
                      Text("Price: \$${item['price']}"),
                    ],
                  ),
                  leading:
                      item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                          ? Image.network(
                              item['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            )
                          : Icon(Icons.book, size: 50),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Delete item from wishlist
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('wishlist')
                          .doc(item['id'])
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Item removed from wishlist")));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
