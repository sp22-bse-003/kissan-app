import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kissan/core/services/tts_service.dart';
import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/di/service_locator.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int currentImageIndex = 0;
  final int totalImages = 4;
  late final CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = ServiceLocator.get<CartService>();
  }

  Future<void> _addToCart() async {
    try {
      final productId =
          widget.product['id']?.toString() ??
          'product_${DateTime.now().millisecondsSinceEpoch}';
      final productName = widget.product['name'] ?? 'Unknown Product';
      final sellerName = widget.product['sellerName'] ?? 'Unknown Seller';
      final weight = widget.product['weight']?.toString() ?? '0 kg';
      final price = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
      final imageUrl =
          widget.product['imageUrl'] ?? widget.product['image'] ?? '';
      final sellerId = widget.product['sellerId'];

      await _cartService.addProductToCart(
        productId: productId,
        productName: productName,
        productBrand: sellerName,
        productWeight: weight,
        productPrice: price,
        productImageUrl: imageUrl,
        sellerId: sellerId,
        quantity: 1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Added to cart!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(Icons.grass, size: 80, color: Colors.green[300]),
        ),
      );
    }

    // If it's a Firebase Storage URL or any http URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          height: 300,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00C853),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading image...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading product image: $error');
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.grass, size: 80, color: Colors.green[300]),
              ),
            );
          },
        ),
      );
    }

    // If it's not a valid URL, show placeholder
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.grass, size: 80, color: Colors.green[300]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String description =
        widget.product['description'] ?? 'No description available.';
    final String sellerName = widget.product['sellerName'] ?? 'Unknown Seller';
    final String sellerPhone =
        widget.product['sellerPhone'] ?? 'No phone provided';
    final String sellerLocation =
        widget.product['sellerLocation'] ?? 'No location specified';

    final String? imageUrl =
        widget.product['imageUrl'] ?? widget.product['image'];
    final int weight = widget.product['weight'] ?? 0;
    final double price = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
    final String category = widget.product['category'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 5),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black),
            onPressed: () async {
              final productName = widget.product['name'] ?? 'Product';
              final text =
                  '$productName. Price: ${price.toStringAsFixed(0)} rupees. $description. Seller: $sellerName. Location: $sellerLocation';
              await TtsService.instance.speak(text);
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: _addToCart,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildProductImage(imageUrl)),
              const SizedBox(height: 16),
              _buildPaginationDots(),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.product['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rs.${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weight', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '$weight kg',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Category', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Handle text-to-speech for description
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 38),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seller Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.volume_up,
                      size: 20,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Handle text-to-speech for seller info
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildSellerInfoRow(Icons.business, sellerName),
              const SizedBox(height: 12),
              _buildSellerInfoRow(Icons.phone, sellerPhone),
              const SizedBox(height: 12),
              _buildSellerInfoRow(Icons.location_on, sellerLocation),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalImages,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                currentImageIndex == index
                    ? Colors.black
                    : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSellerInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
