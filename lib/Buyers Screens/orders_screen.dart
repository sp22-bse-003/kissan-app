import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'order_model.dart';

class OrdersScreen extends StatefulWidget {
  final List<Order> initialOrders;
  const OrdersScreen({super.key, this.initialOrders = const []});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Order> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _allOrders.addAll(widget.initialOrders);
    _simulateOrderStatusChanges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _getPendingOrders() {
    return _allOrders.where((order) => order.overallStatus == OrderStatus.pending).toList();
  }

  List<Order> _getOnTheWayOrders() {
    return _allOrders.where((order) => order.overallStatus == OrderStatus.onTheWay).toList();
  }

  List<Order> _getDeliveredOrders() {
    return _allOrders.where((order) => order.overallStatus == OrderStatus.delivered).toList();
  }

  List<Order> _getCancelledOrders() {
    return _allOrders.where((order) => order.overallStatus == OrderStatus.cancelled).toList();
  }

  void _simulateOrderStatusChanges() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_allOrders.isNotEmpty) {
        setState(() {
          final pendingOrder = _allOrders.firstWhere(
                (o) => o.overallStatus == OrderStatus.pending,
            orElse: () => _allOrders.first,
          );

          if (pendingOrder.products.isNotEmpty) {
            pendingOrder.updateProductStatus(pendingOrder.products[0].name, ProductStatus.accepted);
          }
          if (pendingOrder.products.length > 1) {
            pendingOrder.updateProductStatus(pendingOrder.products[1].name, ProductStatus.rejected);
          }
          if (pendingOrder.products.every((p) => p.status == ProductStatus.accepted)) {
            pendingOrder.overallStatus = OrderStatus.onTheWay;
          } else if (pendingOrder.products.every((p) => p.status == ProductStatus.rejected)) {
            pendingOrder.overallStatus = OrderStatus.cancelled;
          } else {
            pendingOrder.overallStatus = OrderStatus.pending;
          }

          Future.delayed(const Duration(seconds: 10), () {
            if (_allOrders.any((o) => o.overallStatus == OrderStatus.onTheWay)) {
              setState(() {
                _allOrders.firstWhere((o) => o.overallStatus == OrderStatus.onTheWay).overallStatus = OrderStatus.delivered;
              });
            }
          });

          Future.delayed(const Duration(seconds: 7), () {
            if (_allOrders.length > 1 && _allOrders[1].overallStatus == OrderStatus.pending) {
              setState(() {
                _allOrders[1].overallStatus = OrderStatus.cancelled;
              });
            }
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulated seller actions on an order!')),
        );
      }
    });
  }

  Widget _buildOrderCard(Order order, {bool showCancelButton = false}) {
    final DateFormat formatter = DateFormat('MMM dd, HH:mm');

    Color statusColor;
    switch (order.overallStatus) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.onTheWay:
        statusColor = Colors.blue;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.orderId.substring(order.orderId.length - 6)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    order.overallStatus.name.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Date: ${formatter.format(order.orderDate)}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Divider(height: 20, thickness: 1),
            const Text('Items in this order:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...order.products.map((orderedProduct) {
              Color productStatusColor;
              switch (orderedProduct.status) {
                case ProductStatus.pending:
                  productStatusColor = Colors.orange;
                  break;
                case ProductStatus.accepted:
                  productStatusColor = Colors.green;
                  break;
                case ProductStatus.rejected:
                  productStatusColor = Colors.red;
                  break;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.asset(orderedProduct.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderedProduct.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('Qty: ${orderedProduct.quantity} - Rs. ${orderedProduct.itemTotalPrice.toStringAsFixed(2)}'),
                          Text(
                            'Status: ${orderedProduct.status.name.toUpperCase()}',
                            style: TextStyle(fontSize: 12, color: productStatusColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Rs. ${order.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Charges:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Rs. ${order.deliveryCharges.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Delivery Address:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              order.deliveryAddress,
              style: const TextStyle(fontSize: 14),
            ),
            if (showCancelButton && order.overallStatus == OrderStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCancelOrderDialog(order),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelOrderDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: Text('Are you sure you want to cancel order ID: ${order.orderId.substring(order.orderId.length - 6)}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  order.overallStatus = OrderStatus.cancelled;
                  for (var product in order.products) {
                    if (product.status == ProductStatus.pending) {
                      product.status = ProductStatus.rejected;
                    }
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order ${order.orderId.substring(order.orderId.length - 6)} has been cancelled.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          isScrollable: true,
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'ON THE WAY'),
            Tab(text: 'DELIVERED'),
            Tab(text: 'CANCELLED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_getPendingOrders(), showCancelButton: true),
          _buildOrdersList(_getOnTheWayOrders()),
          _buildOrdersList(_getDeliveredOrders()),
          _buildOrdersList(_getCancelledOrders()),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, {bool showCancelButton = false}) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders in this category!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], showCancelButton: showCancelButton);
      },
    );
  }
}