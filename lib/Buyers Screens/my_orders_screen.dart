import 'package:flutter/material.dart';
import 'package:kissan/core/models/order.dart' as order_model;
import 'package:kissan/core/services/order_service.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _orderService = ServiceLocator.get<OrderService>();
  }

  Color _getStatusColor(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return Colors.orange;
      case order_model.OrderStatus.processing:
        return Colors.blue;
      case order_model.OrderStatus.onTheWay:
        return Colors.purple;
      case order_model.OrderStatus.delivered:
        return Colors.green;
      case order_model.OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getProductStatusColor(order_model.ProductOrderStatus status) {
    switch (status) {
      case order_model.ProductOrderStatus.pending:
        return Colors.orange;
      case order_model.ProductOrderStatus.accepted:
        return Colors.green;
      case order_model.ProductOrderStatus.rejected:
        return Colors.red;
      case order_model.ProductOrderStatus.shipped:
        return Colors.blue;
    }
  }

  String _getStatusText(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return 'Pending';
      case order_model.OrderStatus.processing:
        return 'Processing';
      case order_model.OrderStatus.onTheWay:
        return 'On The Way';
      case order_model.OrderStatus.delivered:
        return 'Delivered';
      case order_model.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getProductStatusText(order_model.ProductOrderStatus status) {
    switch (status) {
      case order_model.ProductOrderStatus.pending:
        return 'Pending';
      case order_model.ProductOrderStatus.accepted:
        return 'Accepted';
      case order_model.ProductOrderStatus.rejected:
        return 'Rejected';
      case order_model.ProductOrderStatus.shipped:
        return 'Shipped';
    }
  }

  IconData _getStatusIcon(order_model.OrderStatus status) {
    switch (status) {
      case order_model.OrderStatus.pending:
        return Icons.schedule;
      case order_model.OrderStatus.processing:
        return Icons.sync;
      case order_model.OrderStatus.onTheWay:
        return Icons.local_shipping;
      case order_model.OrderStatus.delivered:
        return Icons.check_circle;
      case order_model.OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<order_model.OrderModel>>(
        stream: _orderService.getUserOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your orders will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(order_model.OrderModel order) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  color: _getStatusColor(order.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${order.id?.substring(0, 8) ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Products List - Separated by Product
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: order.products.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 24, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final product = order.products[index];
              return _buildProductItem(product);
            },
          ),

          // Order Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal:',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Rs. ${order.subtotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery:',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Rs. ${order.deliveryCharges.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(order_model.OrderProduct product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              product.productImageUrl.isEmpty
                  ? Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 30,
                      color: Colors.grey,
                    ),
                  )
                  : product.productImageUrl.startsWith('http')
                  ? Image.network(
                    product.productImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                  )
                  : Image.asset(
                    product.productImageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                  ),
        ),
        const SizedBox(width: 12),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getProductStatusColor(
                        product.status,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getProductStatusText(product.status),
                      style: TextStyle(
                        color: _getProductStatusColor(product.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.productBrand,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                product.productWeight,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qty: ${product.quantity}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Rs. ${product.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Seller: ${product.sellerId}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
