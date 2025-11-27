import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kissan/core/models/order.dart';
import 'package:kissan/core/repositories/order_repository.dart';

class OrderService {
  final OrderRepository _orderRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OrderService(this._orderRepository);

  String? get currentUserId => _auth.currentUser?.uid;

  bool get isUserLoggedIn => _auth.currentUser != null;

  // User operations
  Stream<List<OrderModel>> getUserOrdersStream() {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ User not logged in');
      return Stream.value([]);
    }

    return _orderRepository.getUserOrders(currentUserId!);
  }

  Future<OrderModel?> getOrderDetails(String orderId) async {
    try {
      return await _orderRepository.getOrderById(orderId);
    } catch (e) {
      debugPrint('❌ Error getting order details: $e');
      return null;
    }
  }

  Future<String?> placeOrder(OrderModel order) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ User must be logged in to place order');
      return null;
    }

    try {
      // Set the user ID
      final orderWithUserId = order.copyWith(userId: currentUserId!);

      final orderId = await _orderRepository.createOrder(orderWithUserId);
      debugPrint('✅ Order placed successfully: $orderId');
      return orderId;
    } catch (e) {
      debugPrint('❌ Error placing order: $e');
      return null;
    }
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _orderRepository.cancelOrder(orderId, reason);
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, status);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      return false;
    }
  }

  // Seller operations
  Stream<List<OrderModel>> getSellerOrdersStream(String sellerId) {
    return _orderRepository.getSellerOrders(sellerId);
  }

  Future<bool> updateProductOrderStatus(
    String orderId,
    String productId,
    ProductOrderStatus status,
  ) async {
    try {
      await _orderRepository.updateProductStatus(orderId, productId, status);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating product status: $e');
      return false;
    }
  }
}
