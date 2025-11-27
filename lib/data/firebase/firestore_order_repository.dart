import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kissan/core/models/order.dart';
import 'package:kissan/core/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _sellerOrdersCollection =>
      _firestore.collection('seller_orders');

  @override
  Future<String> createOrder(OrderModel order) async {
    try {
      debugPrint('📦 Creating order for user: ${order.userId}');

      // Create order document
      final docRef = await _ordersCollection.add(order.toMap());
      debugPrint('✅ Order created with ID: ${docRef.id}');

      // Create seller order notifications for each seller
      final sellerIds = order.sellerIds;
      for (final sellerId in sellerIds) {
        final sellerProducts = order.getProductsBySeller(sellerId);

        await _sellerOrdersCollection.add({
          'orderId': docRef.id,
          'sellerId': sellerId,
          'userId': order.userId,
          'products': sellerProducts.map((p) => p.toMap()).toList(),
          'deliveryAddress': order.deliveryAddress,
          'createdAt': Timestamp.fromDate(order.createdAt),
          'status': 'pending',
        });

        debugPrint('📨 Notification sent to seller: $sellerId');
      }

      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      rethrow;
    }
  }

  @override
  Stream<List<OrderModel>> getUserOrders(String userId) {
    debugPrint('📋 Fetching orders for user: $userId');

    return _ordersCollection.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {
        // Sort manually on client side to avoid index requirement
        final orders =
            snapshot.docs.map((doc) {
              return OrderModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

        // Sort by createdAt descending (newest first)
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return orders;
      },
    );
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching order: $e');
      return null;
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      debugPrint('🔄 Updating order $orderId status to: ${status.name}');

      await _ordersCollection.doc(orderId).update({
        'status': status.name,
        'statusUpdatedAt': Timestamp.now(),
      });

      debugPrint('✅ Order status updated');
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      debugPrint('❌ Cancelling order: $orderId');

      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'statusUpdatedAt': Timestamp.now(),
        'cancellationReason': reason,
      });

      debugPrint('✅ Order cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  @override
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    debugPrint('📋 Fetching orders for seller: $sellerId');

    // Get all order IDs for this seller
    return _sellerOrdersCollection
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .asyncMap((snapshot) async {
          // Sort manually on client side to avoid index requirement
          final docs = snapshot.docs.toList();
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['createdAt'] as Timestamp?)?.toDate();
            final bTime = (bData['createdAt'] as Timestamp?)?.toDate();
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Descending
          });

          final orderIds =
              docs
                  .map(
                    (doc) =>
                        (doc.data() as Map<String, dynamic>)['orderId']
                            as String,
                  )
                  .toSet()
                  .toList();

          if (orderIds.isEmpty) return <OrderModel>[];

          // Fetch full order details
          final orders = <OrderModel>[];
          for (final orderId in orderIds) {
            final order = await getOrderById(orderId);
            if (order != null) {
              orders.add(order);
            }
          }

          return orders;
        });
  }

  @override
  Future<void> updateProductStatus(
    String orderId,
    String productId,
    ProductOrderStatus status,
  ) async {
    try {
      debugPrint('🔄 Updating product $productId status to: ${status.name}');

      final orderDoc = await _ordersCollection.doc(orderId).get();
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final products =
          (orderData['products'] as List<dynamic>)
              .map((p) => OrderProduct.fromMap(p as Map<String, dynamic>))
              .toList();

      // Update specific product status
      for (var product in products) {
        if (product.productId == productId) {
          product.status = status;
          product.statusUpdatedAt = DateTime.now();
          break;
        }
      }

      // Check if all products are processed to update overall order status
      OrderStatus newOrderStatus = OrderStatus.pending;

      if (products.every(
        (p) =>
            p.status == ProductOrderStatus.accepted ||
            p.status == ProductOrderStatus.shipped,
      )) {
        newOrderStatus = OrderStatus.processing;
      } else if (products.every(
        (p) => p.status == ProductOrderStatus.shipped,
      )) {
        newOrderStatus = OrderStatus.onTheWay;
      } else if (products.every(
        (p) => p.status == ProductOrderStatus.rejected,
      )) {
        newOrderStatus = OrderStatus.cancelled;
      }

      await _ordersCollection.doc(orderId).update({
        'products': products.map((p) => p.toMap()).toList(),
        'status': newOrderStatus.name,
        'statusUpdatedAt': Timestamp.now(),
      });

      debugPrint('✅ Product status updated');
    } catch (e) {
      debugPrint('❌ Error updating product status: $e');
      rethrow;
    }
  }
}
