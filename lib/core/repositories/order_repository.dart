import 'package:kissan/core/models/order.dart';

abstract class OrderRepository {
  // User orders
  Stream<List<OrderModel>> getUserOrders(String userId);
  Future<OrderModel?> getOrderById(String orderId);
  Future<String> createOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder(String orderId, String reason);

  // Seller orders
  Stream<List<OrderModel>> getSellerOrders(String sellerId);
  Future<void> updateProductStatus(
    String orderId,
    String productId,
    ProductOrderStatus status,
  );
}
