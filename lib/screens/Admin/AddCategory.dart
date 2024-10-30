import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final TextEditingController _nameController = TextEditingController();

  void _addCategory() async {
    final String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      final CollectionReference categories =
          FirebaseFirestore.instance.collection('categories');

      await categories.add({'name': name});

      _nameController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Category Added Successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Category")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Category Name"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCategory,
              child: Text("Add Category"),
            ),
          ],
        ),
      ),
    );
  }
}
