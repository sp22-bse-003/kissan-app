import 'cart_item_widget.dart';

enum OrderStatus {
  pending,
  onTheWay,
  delivered,
  cancelled,
}

enum ProductStatus {
  pending,
  accepted,
  rejected,
}

class OrderedProduct {
  final CartItem productDetails;
  ProductStatus status;

  OrderedProduct({
    required this.productDetails,
    this.status = ProductStatus.pending,
  });

  String get name => productDetails.name;
  int get quantity => productDetails.quantity;
  double get price => productDetails.price;
  String get imageUrl => productDetails.imageUrl;
  double get itemTotalPrice => productDetails.itemTotalPrice;
}

class Order {
  final String orderId;
  final List<OrderedProduct> products;
  final String deliveryAddress;
  final double subtotal;
  final double deliveryCharges;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus overallStatus;

  Order({
    required this.orderId,
    required this.products,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharges,
    required this.totalAmount,
    required this.orderDate,
    this.overallStatus = OrderStatus.pending,
  });

  factory Order.fromCartItems({
    required List<CartItem> selectedCartItems,
    required String address,
    required double deliveryCharges,
  }) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    final List<OrderedProduct> orderedProducts = selectedCartItems
        .map((item) => OrderedProduct(productDetails: item, status: ProductStatus.pending))
        .toList();

    final double sub = orderedProducts.fold(0.0, (sum, p) => sum + p.itemTotalPrice);
    final double total = sub + deliveryCharges;

    return Order(
      orderId: id,
      products: orderedProducts,
      deliveryAddress: address,
      subtotal: sub,
      deliveryCharges: deliveryCharges,
      totalAmount: total,
      orderDate: DateTime.now(),
      overallStatus: OrderStatus.pending,
    );
  }

  void updateProductStatus(String productName, ProductStatus newStatus) {
    for (var product in products) {
      if (product.name == productName) {
        product.status = newStatus;
        _updateOverallStatus();
        break;
      }
    }
  }

  void _updateOverallStatus() {
    if (overallStatus == OrderStatus.cancelled || overallStatus == OrderStatus.delivered) {
      return;
    }

    if (products.every((p) => p.status == ProductStatus.accepted)) {
      overallStatus = OrderStatus.onTheWay;
    } else if (products.every((p) => p.status == ProductStatus.rejected)) {
      overallStatus = OrderStatus.cancelled;
    } else if (products.any((p) => p.status == ProductStatus.pending)) {
      overallStatus = OrderStatus.pending;
    } else if (products.any((p) => p.status == ProductStatus.rejected)) {
      overallStatus = OrderStatus.pending;
    }
  }
}
