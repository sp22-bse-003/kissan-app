import 'package:flutter/material.dart';
import 'cart_item_widget.dart';
import 'orders_screen.dart';
import 'order_model.dart';

class CartScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const CartScreen({super.key, this.scrollController});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late ScrollController _internalScrollController;

  List<CartItem> cartItems = [
    CartItem(
      name: 'Wheat',
      brand: 'Ali Khan Crops',
      weight: '40 kg',
      price: 6000.0,
      imageUrl: 'assets/images/sarsabz urea.png',
      quantity: 1,
      isSelected: true,
    ),
    CartItem(
      name: 'DAP (SONA)',
      brand: 'FFC',
      weight: '40 kg',
      price: 4000.0,
      imageUrl: 'assets/images/sarsabz urea.png',
      quantity: 2,
      isSelected: true,
    ),
    CartItem(
      name: 'Fertilizer A',
      brand: 'Green Farms',
      weight: '25 kg',
      price: 2500.0,
      imageUrl: 'assets/images/sarsabz urea.png',
      quantity: 1,
      isSelected: false,
    ),
    CartItem(
      name: 'Pesticide X',
      brand: 'Agro Solutions',
      weight: '1 Litre',
      price: 1500.0,
      imageUrl: 'assets/images/sarsabz urea.png',
      quantity: 1,
      isSelected: true,
    ),
  ];

  final double deliveryCharges = 250.0;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _internalScrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    _addressController.dispose();
    super.dispose();
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + (item.isSelected ? item.itemTotalPrice : 0.0));
  }

  double get totalAmount {
    if (cartItems.any((item) => item.isSelected)) {
      return subtotal + deliveryCharges;
    }
    return 0.0;
  }

  bool get allItemsSelected => cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);

  void _incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  void _deleteItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _toggleItemSelection(bool? isSelected, int index) {
    setState(() {
      cartItems[index].isSelected = isSelected ?? false;
    });
  }

  void _toggleSelectAll(bool? selectAll) {
    setState(() {
      final bool newSelection = selectAll ?? false;
      for (var item in cartItems) {
        item.isSelected = newSelection;
      }
    });
  }

  void _showOrderConfirmationWithAddress(BuildContext context) {
    final List<CartItem> selectedItems = cartItems.where((item) => item.isSelected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item to buy.')),
      );
      return;
    }

    final double selectedSubtotal = selectedItems.fold(0.0, (sum, item) => sum + item.itemTotalPrice);
    final double selectedTotalAmount = selectedSubtotal + deliveryCharges;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Order & Enter Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text('Selected Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...selectedItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(item.imageUrl, width: 40, height: 40, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Qty: ${item.quantity} - Rs. ${item.itemTotalPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 25, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rs. ${selectedSubtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Charges:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rs. ${deliveryCharges.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(height: 25, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Rs. ${selectedTotalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'Enter your full delivery address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('Please enter a delivery address.')),
                        );
                        return;
                      }

                      final Order newOrder = Order.fromCartItems(
                        selectedCartItems: selectedItems,
                        address: _addressController.text.trim(),
                        deliveryCharges: deliveryCharges,
                      );

                      Navigator.of(sheetContext).pop();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrdersScreen(initialOrders: [newOrder]),
                        ),
                      );

                      setState(() {
                        cartItems.removeWhere((item) => item.isSelected);
                        _addressController.clear();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order Confirmed and Selected Items Moved!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: allItemsSelected,
                      onChanged: _toggleSelectAll,
                      activeColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                    ),
                    const Text('Select All', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add some products to see them here.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _internalScrollController,
                itemCount: cartItems.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return CartItemWidget(
                    item: cartItems[index],
                    onAdd: () => _incrementQuantity(index),
                    onRemove: () => _decrementQuantity(index),
                    onDelete: () => _deleteItem(index),
                    onSelected: (isSelected) => _toggleItemSelection(isSelected, index),
                  );
                },
              ),
            ),
            if (cartItems.isNotEmpty && cartItems.any((item) => item.isSelected))
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal (Selected):', style: TextStyle(fontSize: 16)),
                        Text('Rs. ${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Charges:', style: TextStyle(fontSize: 16)),
                        Text('Rs. ${deliveryCharges.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total (Selected):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Rs. ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showOrderConfirmationWithAddress(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Buy Selected Items',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (cartItems.isNotEmpty && !cartItems.any((item) => item.isSelected))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select items to proceed with purchase.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
