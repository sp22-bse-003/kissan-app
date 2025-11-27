import 'package:flutter/material.dart';
import 'cart_item_widget.dart';
import 'order_confirmation_screen.dart';
import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/models/cart_item.dart';
import 'package:kissan/core/di/service_locator.dart';

class CartScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const CartScreen({super.key, this.scrollController});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late ScrollController _internalScrollController;
  late CartService _cartService;
  bool _isExpanded = false;

  final double deliveryCharges = 250.0;

  @override
  void initState() {
    super.initState();
    _internalScrollController = widget.scrollController ?? ScrollController();
    _cartService = ServiceLocator.get<CartService>();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    super.dispose();
  }

  double _calculateSubtotal(List<CartItemModel> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.isSelected ? item.itemTotalPrice : 0.0),
    );
  }

  double _calculateTotalAmount(List<CartItemModel> items) {
    final subtotal = _calculateSubtotal(items);
    if (items.any((item) => item.isSelected)) {
      return subtotal + deliveryCharges;
    }
    return 0.0;
  }

  bool _allItemsSelected(List<CartItemModel> items) {
    return items.isNotEmpty && items.every((item) => item.isSelected);
  }

  Future<void> _incrementQuantity(CartItemModel item) async {
    try {
      await _cartService.updateQuantity(item.id!, item.quantity + 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating quantity: $e')));
      }
    }
  }

  Future<void> _decrementQuantity(CartItemModel item) async {
    if (item.quantity > 1) {
      try {
        await _cartService.updateQuantity(item.id!, item.quantity - 1);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating quantity: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(CartItemModel item) async {
    try {
      await _cartService.removeFromCart(item.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error removing item: $e')));
      }
    }
  }

  Future<void> _toggleItemSelection(
    CartItemModel item,
    bool? isSelected,
  ) async {
    try {
      await _cartService.toggleSelection(item.id!, isSelected ?? false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating selection: $e')));
      }
    }
  }

  Future<void> _toggleSelectAll(
    List<CartItemModel> items,
    bool? selectAll,
  ) async {
    final bool newSelection = selectAll ?? false;
    try {
      for (var item in items) {
        await _cartService.toggleSelection(item.id!, newSelection);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating selection: $e')));
      }
    }
  }

  void _showOrderConfirmationWithAddress(
    BuildContext context,
    List<CartItemModel> cartItems,
  ) {
    final List<CartItemModel> selectedItems =
        cartItems.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to buy.'),
        ),
      );
      return;
    }

    final double selectedSubtotal = selectedItems.fold(
      0.0,
      (sum, item) => sum + item.itemTotalPrice,
    );
    final double selectedTotalAmount = selectedSubtotal + deliveryCharges;

    // Navigate to order confirmation screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationScreen(
              selectedItems: selectedItems,
              subtotal: selectedSubtotal,
              deliveryCharges: deliveryCharges,
              totalAmount: selectedTotalAmount,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.getCartItemsStream(),
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
                    'Error loading cart',
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

          final cartItems = snapshot.data ?? [];
          final subtotal = _calculateSubtotal(cartItems);
          final totalAmount = _calculateTotalAmount(cartItems);
          final allSelected = _allItemsSelected(cartItems);

          return Column(
            children: [
              if (cartItems.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: allSelected,
                        onChanged: (val) => _toggleSelectAll(cartItems, val),
                        activeColor: const Color(0xFF00C853),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      const Text(
                        'Select All',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child:
                    cartItems.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Your cart is empty!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add some products to see them here.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _internalScrollController,
                          itemCount: cartItems.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return CartItemWidget(
                              item: CartItem(
                                name: item.productName,
                                brand: item.productBrand,
                                weight: item.productWeight,
                                price: item.productPrice,
                                imageUrl: item.productImageUrl,
                                quantity: item.quantity,
                                isSelected: item.isSelected,
                              ),
                              onAdd: () => _incrementQuantity(item),
                              onRemove: () => _decrementQuantity(item),
                              onDelete: () => _deleteItem(item),
                              onSelected:
                                  (isSelected) =>
                                      _toggleItemSelection(item, isSelected),
                            );
                          },
                        ),
              ),
              if (cartItems.isNotEmpty &&
                  cartItems.any((item) => item.isSelected))
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Expand/Collapse button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.grey[600],
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isExpanded ? 'Hide Details' : 'Show Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Expandable details section
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal (Selected):',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Rs. ${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Delivery Charges:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Rs. ${deliveryCharges.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total (Selected):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Rs. ${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        crossFadeState:
                            _isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      // Buy Now button (always visible)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              () => _showOrderConfirmationWithAddress(
                                context,
                                cartItems,
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (cartItems.isNotEmpty &&
                  !cartItems.any((item) => item.isSelected))
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select items to proceed with purchase.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
