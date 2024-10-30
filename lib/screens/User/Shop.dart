import 'package:book_club/screens/User/Cart&Wishlist.dart';
import 'package:book_club/screens/User/detail_page.dart';
import 'package:book_club/screens/login/login.dart';
import 'package:book_club/states/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<String> selectedCategories = [];
  String searchQuery = '';
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> _getFilteredBooksStream() {
    Query query = FirebaseFirestore.instance.collection('books');

    // Filter books by category IDs if categories are selected
    if (selectedCategories.isNotEmpty) {
      query = query.where('category', whereIn: selectedCategories);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot> _getCategoriesStream() {
    return FirebaseFirestore.instance.collection('categories').snapshots();
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

  Future<void> _addToCart(String bookId, Map<String, dynamic> bookData) async {
    final cartDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(bookId);

    DocumentSnapshot cartSnapshot = await cartDoc.get();

    if (cartSnapshot.exists) {
      await cartDoc.update({
        'quantity': cartSnapshot['quantity'] + 1,
      });
    } else {
      await cartDoc.set({
        ...bookData,
        'quantity': 1,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${bookData['name']} added to cart")),
    );
  }

  Future<void> _toggleWishlist(
      String bookId, Map<String, dynamic> bookData) async {
    final wishlistDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(bookId);

    DocumentSnapshot wishlistSnapshot = await wishlistDoc.get();

    if (wishlistSnapshot.exists) {
      await wishlistDoc.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${bookData['name']} removed from wishlist")),
      );
    } else {
      await wishlistDoc.set(bookData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${bookData['name']} added to wishlist")),
      );
    }
  }

  Future<bool> _isInWishlist(String bookId) async {
    final wishlistDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(bookId);

    DocumentSnapshot wishlistSnapshot = await wishlistDoc.get();

    return wishlistSnapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Shop"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.person),
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
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Navigation",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              title: Text("Show Cart"),
              onTap: _navigateToCart,
            ),
            ListTile(
              title: Text("Show Wishlist"),
              onTap: _navigateToWishlist,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by book name or author",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Horizontal Category Filter with Category IDs
          StreamBuilder<QuerySnapshot>(
            stream: _getCategoriesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("No Categories Found"));
              }

              final categories = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((categoryDoc) {
                    final categoryId = categoryDoc.id;
                    final categoryName = categoryDoc['name'];
                    final isSelected = selectedCategories.contains(categoryId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(categoryName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedCategories.add(categoryId);
                            } else {
                              selectedCategories.remove(categoryId);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // Book List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredBooksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No Books Found"));
                }

                final books = snapshot.data!.docs.where((book) {
                  final bookName = book['name'].toLowerCase();
                  final bookAuthor = book['author'].toLowerCase();
                  return bookName.contains(searchQuery) ||
                      bookAuthor.contains(searchQuery);
                }).toList();

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.79,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final bookData = {
                      'id': book.id,
                      'name': book['name'],
                      'author': book['author'],
                      'price': book['price'],
                      'imageUrl': book['imageUrl'],
                      'category': book['category'],
                    };

                    return _buildBookCard(bookData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> bookData) {
    final imageUrl = bookData['imageUrl'] ?? '';
    final name = bookData['name'];
    final author = bookData['author'];
    final price = bookData['price'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailPage(bookData: bookData),
        ),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image, size: 50),
                    )
                  : Icon(Icons.book, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  Text("Author: $author", style: TextStyle(color: Colors.grey)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text("\$$price", style: TextStyle(color: Colors.green)),
            ),
            FutureBuilder<bool>(
              future: _isInWishlist(bookData['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircularProgressIndicator(),
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () => _addToCart(bookData['id'], bookData),
                        ),
                      ],
                    ),
                  );
                }

                final isInWishlist = snapshot.data ?? false;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey,
                        ),
                        onPressed: () =>
                            _toggleWishlist(bookData['id'], bookData),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () => _addToCart(bookData['id'], bookData),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPage()),
    );
  }

  void _navigateToWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WishlistPage()),
    );
  }
}
