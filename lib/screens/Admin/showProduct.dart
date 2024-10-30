import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  // Function to fetch category name based on categoryId
  Future<String> _getCategoryName(String categoryId) async {
    try {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get();
      return categoryDoc.exists ? categoryDoc['name'] : 'Unknown Category';
    } catch (e) {
      return 'Unknown Category';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Books Found"));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final categoryId = book['category'];
              final imageUrl = book['imageUrl']; // Get the image URL

              return FutureBuilder<String>(
                future: _getCategoryName(categoryId),
                builder: (context, categorySnapshot) {
                  String imageUrl = book['imageUrl'] ??
                      ''; // Assuming this is how you get the image URL

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(book['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Author: ${book['author']}"),
                          Text("Length: ${book['length']} pages"),
                          Text("Price: \$${book['price']}"),
                          Text(
                              "Category: ${categorySnapshot.data ?? 'Loading...'}"),
                        ],
                      ),
                      leading: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons
                                    .error); // Show error icon if image fails to load
                              },
                            )
                          : Icon(Icons.book, size: 50),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('books')
                              .doc(book.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Book Deleted")));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
