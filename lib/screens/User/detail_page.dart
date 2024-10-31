import 'package:book_club/states/currentUser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> bookData;

  const BookDetailPage({Key? key, required this.bookData}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    try {
      final querySnapshot = await _firestore
          .collection('books')
          .doc(widget.bookData['id'])
          .collection('reviews')
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => {
                'user': doc['user'],
                'rating': doc['rating'],
                'comment': doc['comment'],
              })
          .toList();

      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  void _submitReview(String userName) async {
    final review = {
      'user': userName,
      'rating': _selectedRating,
      'comment': _reviewController.text,
    };

    try {
      await _firestore
          .collection('books')
          .doc(widget.bookData['id'])
          .collection('reviews')
          .add(review);

      setState(() {
        _reviews.add(review);
        _reviewController.clear();
        _selectedRating = 0;
      });

      print('Review submitted');
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _selectedRating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildOldReviews() {
    if (_reviews.isEmpty) {
      return Text('No reviews yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _reviews.map((review) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review['user'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ),
              Text(review['comment']),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUser>(context).getCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookData['name']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.bookData['imageUrl'] != null &&
                widget.bookData['imageUrl'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    16.0), // Adjust the radius value as needed
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.network(
                      widget.bookData['imageUrl'],
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
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
              widget.bookData['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Author: ${widget.bookData['author']}",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "\$${widget.bookData['price']}",
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement add to wishlist functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement add to cart functionality
                  },
                ),
              ],
            ),
            Divider(),
            Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildOldReviews(),
            Divider(),
            Text(
              'Write a Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildRatingStars(),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (currentUser != null) {
                  _submitReview(currentUser.fullName!);
                } else {
                  print('User is not logged in');
                }
              },
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
