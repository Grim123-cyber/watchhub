class Product {
  final String id;
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: _getPrice(data['price']),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  static int _getPrice(dynamic price) {
    if (price is int) {
      return price;
    }

    if (price is double) {
      return price.toInt();
    }

    if (price is num) {
      return price.toInt();
    }

    return int.tryParse(
          price.toString(),
        ) ??
        0;
  }
}