class Product {
  final String id;
  final String name;
  final String size;
  final String description;
  final double? price; 
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    this.price,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        size: (json['size'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
        imageUrl: (json['imageUrl'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['imageUrl'] as String,
      );
}