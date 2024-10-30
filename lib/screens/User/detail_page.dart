import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> bookData;

  const BookDetailPage({Key? key, required this.bookData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookData['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bookData['imageUrl'] != null && bookData['imageUrl'].isNotEmpty)
              Center(
                child: Image.network(
                  bookData['imageUrl'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.book,
                  size: 200,
                  color: Colors.grey,
                ),
              ),
            SizedBox(height: 16),
            Text(
              bookData['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Author: ${bookData['author']}",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "\$${bookData['price']}",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 16),
            // Add more book details here
          ],
        ),
      ),
    );
  }
}
