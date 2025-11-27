import 'package:flutter/material.dart';
import 'package:kissan/core/models/cart_item.dart';
import 'package:kissan/core/models/order.dart' as order_model;
import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/services/order_service.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'orders_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final List<CartItemModel> selectedItems;
  final double subtotal;
  final double deliveryCharges;
  final double totalAmount;

  const OrderConfirmationScreen({
    super.key,
    required this.selectedItems,
    required this.subtotal,
    required this.deliveryCharges,
    required this.totalAmount,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  late CartService _cartService;
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _cartService = ServiceLocator.get<CartService>();
    _orderService = ServiceLocator.get<OrderService>();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Create order products with dummy seller IDs
    final orderProducts =
        widget.selectedItems.map((item) {
          return order_model.OrderProduct(
            productId:
                item.id ?? 'product_${DateTime.now().millisecondsSinceEpoch}',
            productName: item.productName,
            productBrand: item.productBrand,
            productWeight: item.productWeight,
            productPrice: item.productPrice,
            productImageUrl: item.productImageUrl,
            quantity: item.quantity,
            sellerId:
                'seller_${(item.productName.hashCode % 5) + 1}', // Dummy seller ID
          );
        }).toList();

    // Create the order
    final order = order_model.OrderModel(
      userId: '', // Will be set by service
      products: orderProducts,
      deliveryAddress: _addressController.text.trim(),
      subtotal: widget.subtotal,
      deliveryCharges: widget.deliveryCharges,
      totalAmount: widget.totalAmount,
      createdAt: DateTime.now(),
    );

    // Place order in Firebase
    final orderId = await _orderService.placeOrder(order);

    if (orderId == null) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Remove selected items from cart
    try {
      await _cartService.removeSelectedItems();
    } catch (e) {
      debugPrint('Error removing items from cart: $e');
    }

    if (mounted) {
      // Navigate to orders screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Order placed successfully!'),
            ],
          ),
          backgroundColor: Color(0xFF00C853),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Confirm Order',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00E676)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.selectedItems.length} ${widget.selectedItems.length == 1 ? 'Item' : 'Items'} Selected',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Order Items Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF00C853),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...widget.selectedItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  item.productImageUrl.isEmpty
                                      ? Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      )
                                      : item.productImageUrl.startsWith('http')
                                      ? Image.network(
                                        item.productImageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 35,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      )
                                      : Image.asset(
                                        item.productImageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.shopping_bag,
                                                size: 35,
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
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.productBrand,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.productWeight,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Qty: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Rs. ${item.itemTotalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF00C853),
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
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Price Breakdown Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                      const Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: Color(0xFF00C853),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Price Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        'Subtotal',
                        'Rs. ${widget.subtotal.toStringAsFixed(0)}',
                        false,
                      ),
                      const SizedBox(height: 12),
                      _buildPriceRow(
                        'Delivery Charges',
                        'Rs. ${widget.deliveryCharges.toStringAsFixed(0)}',
                        false,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 1),
                      ),
                      _buildPriceRow(
                        'Total Amount',
                        'Rs. ${widget.totalAmount.toStringAsFixed(0)}',
                        true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Delivery Address Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF00C853),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter your complete delivery address',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00C853),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your delivery address';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a complete address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Place Order Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Place Order',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF00C853) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
