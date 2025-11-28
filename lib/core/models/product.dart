class Product {
  final String? id;
  final String name;
  final double price;
  final int quantity;
  final String category;
  final String description;
  final String? imageUrl; // Can be an asset path or network URL
  final String? sellerId; // Firebase Auth UID of the seller
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    required this.description,
    this.imageUrl,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.sellerLocation,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? description,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    String? sellerLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? id}) {
    return Product(
      id: id ?? map['id']?.toString(),
      name: map['name'] ?? '',
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : (map['price'] is String)
              ? double.tryParse(map['price']) ?? 0
              : (map['price'] ?? 0.0) as double,
      quantity:
          map['quantity'] is String
              ? int.tryParse(map['quantity']) ?? 0
              : (map['quantity'] ?? 0) as int,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      sellerId: map['sellerId'],
      sellerName: map['sellerName'],
      sellerPhone: map['sellerPhone'],
      sellerLocation: map['sellerLocation'],
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] is DateTime
                  ? map['createdAt']
                  : DateTime.tryParse(map['createdAt'].toString()))
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] is DateTime
                  ? map['updatedAt']
                  : DateTime.tryParse(map['updatedAt'].toString()))
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'category': category,
    'description': description,
    'imageUrl': imageUrl,
    if (sellerId != null) 'sellerId': sellerId,
    'sellerName': sellerName,
    'sellerPhone': sellerPhone,
    'sellerLocation': sellerLocation,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}
