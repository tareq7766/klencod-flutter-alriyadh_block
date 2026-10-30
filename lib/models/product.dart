class Product {
  final String id;
  final String name;
  final String size;
  final String description;
  final double? price;
  final String? imagePath;

  const Product({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    this.price,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'description': description,
        'price': price,
        'imagePath': imagePath,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        size: (json['size'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
        imagePath: (json['imagePath'] as String?)?.trim().isEmpty ?? true
            ? null
            : json['imagePath'] as String,
      );
}