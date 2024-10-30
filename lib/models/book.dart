class OurBook {
  String id;
  String name;
  String author;
  int length;
  int price;
  String categoryId; // ID or name of the category for the book

  OurBook({
    required this.id,
    required this.name,
    required this.author,
    required this.length,
    required this.price,
    required this.categoryId, // new field for category
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'length': length,
      'price': price,
      'categoryId': categoryId,
    };
  }

  // Create an OurBook instance from a Firestore document
  factory OurBook.fromMap(Map<String, dynamic> map) {
    return OurBook(
      id: map['id'] as String,
      name: map['name'] as String,
      author: map['author'] as String,
      length: map['length'] as int,
      price: map['price'] as int,
      categoryId: map['categoryId'] as String,
    );
  }
}
