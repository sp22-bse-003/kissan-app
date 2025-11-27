/// Cart Item Model for Firebase storage
class CartItemModel {
  final String? id; // Cart item document ID in Firestore
  final String productId; // Reference to the product
  final String productName;
  final String productBrand;
  final String productWeight;
  final double productPrice;
  final String productImageUrl;
  final int quantity;
  final bool isSelected;
  final DateTime addedAt;
  final DateTime? updatedAt;

  CartItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.productWeight,
    required this.productPrice,
    required this.productImageUrl,
    this.quantity = 1,
    this.isSelected = true,
    DateTime? addedAt,
    this.updatedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Calculate total price for this cart item
  double get itemTotalPrice => productPrice * quantity;

  /// Copy with method for updating cart items
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productBrand,
    String? productWeight,
    double? productPrice,
    String? productImageUrl,
    int? quantity,
    bool? isSelected,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      productWeight: productWeight ?? this.productWeight,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productBrand': productBrand,
      'productWeight': productWeight,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'isSelected': isSelected,
      'addedAt': addedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore Map
  factory CartItemModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CartItemModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productBrand: map['productBrand'] ?? '',
      productWeight: map['productWeight'] ?? '',
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      productImageUrl: map['productImageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
      isSelected: map['isSelected'] ?? true,
      addedAt:
          map['addedAt'] != null
              ? DateTime.parse(map['addedAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(id: $id, productName: $productName, quantity: $quantity, price: $productPrice)';
  }
}
