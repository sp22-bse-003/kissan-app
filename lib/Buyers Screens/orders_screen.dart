import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kissan/core/models/order.dart' as order_model;
import 'package:kissan/core/models/cart_item.dart';
import 'package:kissan/core/services/order_service.dart';
import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/di/service_locator.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderService _orderService;
  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _orderService = ServiceLocator.get<OrderService>();
    _cartService = ServiceLocator.get<CartService>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<order_model.OrderModel> _getPendingOrders(
    List<order_model.OrderModel> allOrders,
  ) {
    return allOrders
        .where((order) => order.status == order_model.OrderStatus.pending)
        .toList();
  }

  List<order_model.OrderModel> _getProcessingOrders(
    List<order_model.OrderModel> allOrders,
  ) {
    return allOrders
        .where(
          (order) =>
              order.status == order_model.OrderStatus.processing ||
              order.status == order_model.OrderStatus.onTheWay,
        )
        .toList();
  }

  List<order_model.OrderModel> _getDeliveredOrders(
    List<order_model.OrderModel> allOrders,
  ) {
    return allOrders
        .where((order) => order.status == order_model.OrderStatus.delivered)
        .toList();
  }

  List<order_model.OrderModel> _getCancelledOrders(
    List<order_model.OrderModel> allOrders,
  ) {
    return allOrders
        .where((order) => order.status == order_model.OrderStatus.cancelled)
        .toList();
  }

  Widget _buildProductCard(
    order_model.OrderProduct product,
    order_model.OrderModel order, {
    bool showCancelButton = false,
  }) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (product.status) {
      case order_model.ProductOrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        statusText = 'PENDING';
        break;
      case order_model.ProductOrderStatus.accepted:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = 'ACCEPTED';
        break;
      case order_model.ProductOrderStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = 'REJECTED';
        break;
      case order_model.ProductOrderStatus.shipped:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping_outlined;
        statusText = 'SHIPPED';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Product Info Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            product.productImageUrl.isEmpty
                                ? Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[300]!,
                                        Colors.grey[200]!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                )
                                : product.productImageUrl.startsWith('http')
                                ? Image.network(
                                  product.productImageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey[300]!,
                                              Colors.grey[200]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                )
                                : Image.asset(
                                  product.productImageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey[300]!,
                                              Colors.grey[200]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 16, color: statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Order Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatter.format(order.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey[200],
                ),
              ),
              // Pricing Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 18,
                                color: Color(0xFF00C853),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unit Price',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Rs. ${product.productPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${product.quantity}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delivery Address Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: null, // Allow unlimited lines
                      ),
                    ),
                  ],
                ),
              ),
              // Total Price Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00E676)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rs. ${product.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Cancel Icon in top right corner
          if (showCancelButton &&
              product.status == order_model.ProductOrderStatus.pending)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showCancelProductDialog(order, product),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelProductDialog(
    order_model.OrderModel order,
    order_model.OrderProduct product,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 10),
              const Text('Cancel Product?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to cancel this product?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Product will be added back to your cart',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          product.productImageUrl.isEmpty
                              ? Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.shopping_bag, size: 25),
                              )
                              : product.productImageUrl.startsWith('http')
                              ? Image.network(
                                product.productImageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 25,
                                      ),
                                    ),
                              )
                              : Image.asset(
                                product.productImageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.shopping_bag,
                                        size: 25,
                                      ),
                                    ),
                              ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Rs. ${product.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No, Keep It',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Create cart item from order product
                  final cartItem = CartItemModel(
                    productId: product.productId,
                    productName: product.productName,
                    productBrand: product.productBrand,
                    productWeight: product.productWeight,
                    productPrice: product.productPrice,
                    productImageUrl: product.productImageUrl,
                    quantity: product.quantity,
                    isSelected: true,
                  );

                  // Add back to cart
                  await _cartService.addToCart(cartItem);

                  // Update product status to rejected so it moves out of pending
                  await _orderService.updateProductOrderStatus(
                    order.id!,
                    product.productId,
                    order_model.ProductOrderStatus.rejected,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${product.productName} cancelled and added back to cart',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add to cart: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'ON THE WAY'),
            Tab(text: 'DELIVERED'),
            Tab(text: 'CANCELLED'),
          ],
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
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final allOrders = snapshot.data ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(
                _getPendingOrders(allOrders),
                showCancelButton: true,
              ),
              _buildOrdersList(_getProcessingOrders(allOrders)),
              _buildOrdersList(_getDeliveredOrders(allOrders)),
              _buildOrdersList(_getCancelledOrders(allOrders)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(
    List<order_model.OrderModel> orders, {
    bool showCancelButton = false,
  }) {
    // Flatten orders to get all products with their parent order
    final List<Map<String, dynamic>> allProducts = [];
    for (var order in orders) {
      for (var product in order.products) {
        // Filter products based on current tab
        // For pending tab, only show pending products
        // For on the way tab, show accepted and shipped products
        // For delivered/cancelled, filter by overall order status
        bool shouldInclude = false;

        if (showCancelButton) {
          // Pending tab - only show pending products
          shouldInclude =
              product.status == order_model.ProductOrderStatus.pending;
        } else if (order.status == order_model.OrderStatus.processing ||
            order.status == order_model.OrderStatus.onTheWay) {
          // On the way tab - show accepted and shipped products
          shouldInclude =
              product.status == order_model.ProductOrderStatus.accepted ||
              product.status == order_model.ProductOrderStatus.shipped;
        } else if (order.status == order_model.OrderStatus.delivered) {
          // Delivered tab - show all products (order is delivered)
          shouldInclude = true;
        } else if (order.status == order_model.OrderStatus.cancelled) {
          // Cancelled tab - show rejected products
          shouldInclude =
              product.status == order_model.ProductOrderStatus.rejected;
        }

        if (shouldInclude) {
          allProducts.add({'product': product, 'order': order});
        }
      }
    }

    if (allProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No products in this category!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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
      itemCount: allProducts.length,
      itemBuilder: (context, index) {
        final productData = allProducts[index];
        return _buildProductCard(
          productData['product'] as order_model.OrderProduct,
          productData['order'] as order_model.OrderModel,
          showCancelButton: showCancelButton,
        );
      },
    );
  }
}
