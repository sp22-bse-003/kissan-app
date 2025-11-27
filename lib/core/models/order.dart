import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, onTheWay, delivered, cancelled }

enum ProductOrderStatus { pending, accepted, rejected, shipped }

class OrderProduct {
  final String productId;
  final String productName;
  final String productBrand;
  final String productWeight;
  final double productPrice;
  final String productImageUrl;
  final int quantity;
  final String sellerId; // Seller who owns this product
  ProductOrderStatus status;
  DateTime? statusUpdatedAt;

  OrderProduct({
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.productWeight,
    required this.productPrice,
    required this.productImageUrl,
    required this.quantity,
    required this.sellerId,
    this.status = ProductOrderStatus.pending,
    this.statusUpdatedAt,
  });

  double get totalPrice => productPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productBrand': productBrand,
      'productWeight': productWeight,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'sellerId': sellerId,
      'status': status.name,
      'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
    };
  }

  factory OrderProduct.fromMap(Map<String, dynamic> map) {
    return OrderProduct(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productBrand: map['productBrand'] ?? '',
      productWeight: map['productWeight'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      productImageUrl: map['productImageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
      sellerId: map['sellerId'] ?? 'seller_001',
      status: ProductOrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProductOrderStatus.pending,
      ),
      statusUpdatedAt:
          map['statusUpdatedAt'] != null
              ? DateTime.parse(map['statusUpdatedAt'])
              : null,
    );
  }
}

class OrderModel {
  final String? id;
  final String userId;
  final List<OrderProduct> products;
  final String deliveryAddress;
  final double subtotal;
  final double deliveryCharges;
  final double totalAmount;
  final DateTime createdAt;
  OrderStatus status;
  DateTime? statusUpdatedAt;
  String? cancellationReason;

  OrderModel({
    this.id,
    required this.userId,
    required this.products,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharges,
    required this.totalAmount,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.statusUpdatedAt,
    this.cancellationReason,
  });

  // Get unique seller IDs from products
  List<String> get sellerIds =>
      products.map((p) => p.sellerId).toSet().toList();

  // Get products for a specific seller
  List<OrderProduct> getProductsBySeller(String sellerId) {
    return products.where((p) => p.sellerId == sellerId).toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'products': products.map((p) => p.toMap()).toList(),
      'deliveryAddress': deliveryAddress,
      'subtotal': subtotal,
      'deliveryCharges': deliveryCharges,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'statusUpdatedAt':
          statusUpdatedAt != null ? Timestamp.fromDate(statusUpdatedAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      products:
          (map['products'] as List<dynamic>?)
              ?.map((p) => OrderProduct.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      deliveryAddress: map['deliveryAddress'] ?? '',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryCharges: (map['deliveryCharges'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      statusUpdatedAt: (map['statusUpdatedAt'] as Timestamp?)?.toDate(),
      cancellationReason: map['cancellationReason'],
    );
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderProduct>? products,
    String? deliveryAddress,
    double? subtotal,
    double? deliveryCharges,
    double? totalAmount,
    DateTime? createdAt,
    OrderStatus? status,
    DateTime? statusUpdatedAt,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      products: products ?? this.products,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
