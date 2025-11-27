import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kissan/core/models/cart_item.dart';
import 'package:kissan/core/repositories/cart_repository.dart';
import 'package:kissan/data/firebase/firestore_cart_repository.dart';

/// Cart Service to manage cart operations with user authentication
class CartService {
  final CartRepository _cartRepository;
  final FirebaseAuth _auth;

  CartService({CartRepository? cartRepository, FirebaseAuth? auth})
    : _cartRepository = cartRepository ?? FirestoreCartRepository(),
      _auth = auth ?? FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  /// Get cart items stream for current user
  Stream<List<CartItemModel>> getCartItemsStream() {
    if (currentUserId == null) {
      if (kDebugMode) {
        print('⚠️ No user logged in, returning empty cart');
      }
      return Stream.value([]);
    }
    return _cartRepository.getCartItems(currentUserId!);
  }

  /// Add item to cart
  Future<void> addToCart(CartItemModel item) async {
    if (currentUserId == null) {
      throw Exception('User must be logged in to add items to cart');
    }
    await _cartRepository.addToCart(currentUserId!, item);
  }

  /// Update cart item
  Future<void> updateCartItem(CartItemModel item) async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }
    await _cartRepository.updateCartItem(currentUserId!, item);
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }
    await _cartRepository.removeFromCart(currentUserId!, cartItemId);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }
    await _cartRepository.clearCart(currentUserId!);
  }

  /// Update item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }
    await _cartRepository.updateQuantity(currentUserId!, cartItemId, quantity);
  }

  /// Toggle item selection
  Future<void> toggleSelection(String cartItemId, bool isSelected) async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }
    await _cartRepository.toggleSelection(
      currentUserId!,
      cartItemId,
      isSelected,
    );
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    if (currentUserId == null) return 0;
    return await _cartRepository.getCartItemCount(currentUserId!);
  }

  /// Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    if (currentUserId == null) return false;
    return await _cartRepository.isProductInCart(currentUserId!, productId);
  }

  /// Remove selected items (after order placement)
  Future<void> removeSelectedItems() async {
    if (currentUserId == null) {
      throw Exception('User must be logged in');
    }

    final repo = _cartRepository;
    if (repo is FirestoreCartRepository) {
      await repo.removeSelectedItems(currentUserId!);
    }
  }

  /// Add product to cart (simplified method)
  Future<void> addProductToCart({
    required String productId,
    required String productName,
    required String productBrand,
    required String productWeight,
    required double productPrice,
    required String productImageUrl,
    int quantity = 1,
  }) async {
    final cartItem = CartItemModel(
      productId: productId,
      productName: productName,
      productBrand: productBrand,
      productWeight: productWeight,
      productPrice: productPrice,
      productImageUrl: productImageUrl,
      quantity: quantity,
    );

    await addToCart(cartItem);
  }
}
