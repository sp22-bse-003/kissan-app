// 🛒 Example: Add to Cart Button in Product Details Screen
// Add this code to your product_details_screen.dart

import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/di/service_locator.dart';

// In your product details screen state class, add:
late final CartService _cartService;

@override
void initState() {
  super.initState();
  _cartService = ServiceLocator.get<CartService>();
}

// Add this method:
Future<void> _addToCart() async {
  try {
    await _cartService.addProductToCart(
      productId: widget.product.id!,
      productName: widget.product.name,
      productBrand: widget.product.sellerName ?? 'Unknown Seller',
      productWeight: widget.product.category, // or add a weight field to Product model
      productPrice: widget.product.price,
      productImageUrl: widget.product.imageUrl ?? 'assets/images/placeholder.png',
      quantity: 1, // or use a quantity selector
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Added to cart!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to cart
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// In your build method, add the button:
Widget _buildAddToCartButton() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    child: ElevatedButton.icon(
      onPressed: _addToCart,
      icon: const Icon(Icons.shopping_cart),
      label: const Text(
        'Add to Cart',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

// =====================================================
// 🛒 Example: Quick Add to Cart from Products List
// Add this in products_screen.dart for each product card
// =====================================================

// Add cart service in state:
late final CartService _cartService;

@override
void initState() {
  super.initState();
  _cartService = ServiceLocator.get<CartService>();
}

// Quick add method:
Future<void> _quickAddToCart(model.Product product) async {
  try {
    await _cartService.addProductToCart(
      productId: product.id!,
      productName: product.name,
      productBrand: product.sellerName ?? 'Unknown',
      productWeight: product.category,
      productPrice: product.price,
      productImageUrl: product.imageUrl ?? 'assets/images/placeholder.png',
      quantity: 1,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
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

// In product card widget, add a small cart icon:
IconButton(
  icon: const Icon(Icons.add_shopping_cart, size: 20),
  onPressed: () => _quickAddToCart(product),
  color: Colors.green,
  tooltip: 'Add to cart',
)

// =====================================================
// 🎯 Check if Product is Already in Cart
// =====================================================

Future<bool> _checkIfInCart(String productId) async {
  return await _cartService.isProductInCart(productId);
}

// Show different button if already in cart:
Widget _buildCartButton(model.Product product) {
  return FutureBuilder<bool>(
    future: _checkIfInCart(product.id!),
    builder: (context, snapshot) {
      final isInCart = snapshot.data ?? false;

      if (isInCart) {
        return OutlinedButton.icon(
          onPressed: () {
            // Navigate to cart
            Navigator.pushNamed(context, '/cart');
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('In Cart'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
            side: const BorderSide(color: Colors.green),
          ),
        );
      }

      return ElevatedButton.icon(
        onPressed: () => _quickAddToCart(product),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add to Cart'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
      );
    },
  );
}

// =====================================================
// 🔔 Show Cart Badge with Item Count
// =====================================================

// In main_navigation.dart or wherever you have bottom nav:
Widget _buildCartIcon() {
  return FutureBuilder<int>(
    future: _cartService.getCartItemCount(),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;

      return Stack(
        children: [
          const Icon(Icons.shopping_cart),
          if (count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  );
}

// Use in BottomNavigationBarItem:
BottomNavigationBarItem(
  icon: _buildCartIcon(),
  label: 'Cart',
)

// =====================================================
// 📝 Firebase Security Rules (IMPORTANT!)
// Deploy these rules to protect user carts
// =====================================================

/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User cart - only owner can read/write
    match /users/{userId}/cart/{cartItemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products - everyone can read, only authenticated can write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
*/

// Deploy command:
// firebase deploy --only firestore:rules
