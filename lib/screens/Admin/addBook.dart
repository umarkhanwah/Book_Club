import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  Uint8List? _imageBytes; // Stores the image bytes for web compatibility

  // Image picker function for web using file_picker
  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes; // Store bytes directly
      });
    }
  }

  // Upload image to Firebase Storage and get its URL
  Future<String?> _uploadImage(Uint8List imageBytes) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('book_images/${DateTime.now().toString()}');
    final uploadTask = storageRef.putData(imageBytes); // Upload bytes
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  // Add book to Firestore with image URL
  void _addBook() async {
    final String name = _nameController.text.trim();
    final String author = _authorController.text.trim();
    final int? length = int.tryParse(_lengthController.text);
    final int? price = int.tryParse(_priceController.text);

    // Debugging prints to ensure variables are populated
    print(
        "Name: $name, Author: $author, Length: $length, Price: $price, Category: $_selectedCategory, ImageBytes: $_imageBytes");

    if (name.isNotEmpty &&
        author.isNotEmpty &&
        length != null &&
        price != null &&
        _selectedCategory != null &&
        _imageBytes != null) {
      try {
        // Upload image and get URL
        final imageUrl = await _uploadImage(_imageBytes!);
        print("Image URL: $imageUrl");

        // Add book data to Firestore
        final CollectionReference books =
            FirebaseFirestore.instance.collection('books');
        await books.add({
          'name': name,
          'author': author,
          'length': length,
          'price': price,
          'category': _selectedCategory,
          'imageUrl': imageUrl, // Store image URL in Firestore
        });
        print("Book added to Firestore");

        // Clear inputs after adding book
        _nameController.clear();
        _authorController.clear();
        _lengthController.clear();
        _priceController.clear();
        setState(() {
          _imageBytes = null;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Book Added Successfully")));
      } catch (e) {
        print("Error adding book: $e"); // Print error to console
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to add book: $e")));
      }
    } else {
      print("Form validation failed.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill all fields and select an image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Book")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Book Name"),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(labelText: "Author"),
            ),
            TextField(
              controller: _lengthController,
              decoration: InputDecoration(labelText: "Length"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final categories = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  hint: Text("Select Category"),
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category['name']),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 10),
            _imageBytes == null
                ? Text("No Image Selected")
                : Text("Image Selected"),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Button pressed");
                _addBook();
              },
              child: Text("Add Book"),
            ),
          ],
        ),
      ),
    );
  }
}
