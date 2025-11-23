import 'package:flutter/material.dart';
import './order_details_screen.dart';
import '../widgets/custom_drawer.dart';
import '../shared/user_data.dart';
import 'package:kissan/core/widgets/tts_icon_button.dart';

class Order {
  final String id;
  final String title;
  final String timestamp;
  String status;
  final String image;
  final int quantity;
  final int pricePerUnit;
  final String address;

  Order({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.status,
    required this.image,
    required this.quantity,
    required this.pricePerUnit,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp,
      'status': status,
      'image': image,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'address': address,
    };
  }

  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String? ?? '#0000',
      title: map['title'] as String? ?? 'Unknown Product',
      timestamp: map['timestamp'] as String? ?? 'Unknown time',
      status: map['status'] as String? ?? 'Pending',
      image: map['image'] as String? ?? 'assets/fertilizer.png',
      quantity:
          map['quantity'] != null
              ? int.tryParse(map['quantity'].toString()) ?? 0
              : 0,
      pricePerUnit:
          map['pricePerUnit'] != null
              ? int.tryParse(map['pricePerUnit'].toString()) ?? 0
              : 0,
      address: map['address'] as String? ?? 'No address provided',
    );
  }
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All Orders';
  final List<Order> _allOrders = [
    Order(
      id: '#1001',
      title: 'DAP (SONA)...',
      timestamp: '15 min ago',
      status: 'Pending',
      image: 'assets/images/dap.png',
      quantity: 2,
      pricePerUnit: 4000,
      address: 'Labor Colony Flat 147/5 Zone B',
    ),
    Order(
      id: '#1002',
      title: 'Sarsabz Urea...',
      timestamp: '2 hours ago',
      status: 'Shipped',
      image: 'assets/images/sarsabz_urea.png',
      quantity: 1,
      pricePerUnit: 4000,
      address: 'Green Town Street 5, House 23',
    ),
    Order(
      id: '#1003',
      title: 'Sarsabz Slopi...',
      timestamp: '1 day ago',
      status: 'Cancelled',
      image: 'assets/images/sarsabz_slopi.png',
      quantity: 3,
      pricePerUnit: 4000,
      address: 'Model Town Block C, House 78',
    ),
    Order(
      id: '#1004',
      title: 'DAP (SONA)...',
      timestamp: '2 days ago',
      status: 'Shipped',
      image: 'assets/images/dap.png',
      quantity: 2,
      pricePerUnit: 4000,
      address: 'Johar Town Block A, House 45',
    ),
    Order(
      id: '#1005',
      title: 'Sarsabz Urea...',
      timestamp: '3 days ago',
      status: 'Pending',
      image: 'assets/images/sarsabz_urea.png',
      quantity: 1,
      pricePerUnit: 4000,
      address: 'Iqbal Town Main Road, Shop 12',
    ),
    Order(
      id: '#1006',
      title: 'Sarsabz Slopi...',
      timestamp: '4 days ago',
      status: 'Delivered',
      image: 'assets/images/sarsabz_slopi.png',
      quantity: 1,
      pricePerUnit: 4000,
      address: 'Iqbal Town Main Road, Shop 12',
    ),
  ];

  List<Order> _filteredOrders = [];

  @override
  void initState() {
    _filteredOrders = _allOrders;
    super.initState();
  }

  void _filterOrders(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All Orders') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders =
            _allOrders.where((order) => order.status == filter).toList();
      }
    });
  }

  void _updateOrderStatus(Order updatedOrder, String newStatus) {
    setState(() {
      final index = _allOrders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        _allOrders[index].status = newStatus;
      }

      _filterOrders(_selectedFilter);
    });
  }

  Future<void> _navigateToOrderDetails(Order order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderDetailsScreen(
              orderData: order.toMap(),
              onStatusUpdate: _updateOrderStatus,
            ),
      ),
    );

    if (result != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: const Text('KISSAN', style: TextStyle(color: Colors.green)),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.grey,
      ),
      drawer: CustomDrawer(imagePath: sharedProfileImagePath),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterButtons(),
          Expanded(
            child:
                _filteredOrders.isEmpty
                    ? const Center(
                      child: Text(
                        'No orders found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = [
      'All Orders',
      'Pending',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              filters
                  .map(
                    (text) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildFilterButton(text),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = _selectedFilter == text;
    return InkWell(
      onTap: () => _filterOrders(text),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 70,
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  order.image.isNotEmpty
                      ? Image.asset(
                        order.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.shopping_bag,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TtsIconButton(text: order.title, iconSize: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.timestamp,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
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
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(order.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToOrderDetails(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          minimumSize: const Size(60, 30),
                        ),
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
