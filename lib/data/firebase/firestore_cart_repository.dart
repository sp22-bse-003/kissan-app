import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kissan/core/models/cart_item.dart';
import 'package:kissan/core/repositories/cart_repository.dart';

/// Firebase implementation of CartRepository
class FirestoreCartRepository implements CartRepository {
  final FirebaseFirestore _firestore;

  FirestoreCartRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the cart collection reference for a user
  CollectionReference _getUserCartCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  @override
  Stream<List<CartItemModel>> getCartItems(String userId) {
    return _getUserCartCollection(
      userId,
    ).orderBy('addedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItemModel.fromMap(
          doc.data() as Map<String, dynamic>,
          id: doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> addToCart(String userId, CartItemModel item) async {
    try {
      // Check if product already exists in cart
      final existingItems =
          await _getUserCartCollection(
            userId,
          ).where('productId', isEqualTo: item.productId).get();

      if (existingItems.docs.isNotEmpty) {
        // If product exists, update quantity instead
        final existingDoc = existingItems.docs.first;
        final existingItem = CartItemModel.fromMap(
          existingDoc.data() as Map<String, dynamic>,
          id: existingDoc.id,
        );

        await updateCartItem(
          userId,
          existingItem.copyWith(
            quantity: existingItem.quantity + item.quantity,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        // Add new item
        await _getUserCartCollection(userId).add(item.toMap());
      }

      if (kDebugMode) {
        print('✅ Item added to cart for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding to cart: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateCartItem(String userId, CartItemModel item) async {
    try {
      if (item.id == null) {
        throw Exception('Cart item ID is required for update');
      }

      await _getUserCartCollection(
        userId,
      ).doc(item.id).update(item.copyWith(updatedAt: DateTime.now()).toMap());

      if (kDebugMode) {
        print('✅ Cart item updated: ${item.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating cart item: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await _getUserCartCollection(userId).doc(cartItemId).delete();

      if (kDebugMode) {
        print('✅ Item removed from cart: $cartItemId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing from cart: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final batch = _firestore.batch();
      final cartItems = await _getUserCartCollection(userId).get();

      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Cart cleared for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing cart: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateQuantity(
    String userId,
    String cartItemId,
    int quantity,
  ) async {
    try {
      if (quantity < 1) {
        throw Exception('Quantity must be at least 1');
      }

      await _getUserCartCollection(userId).doc(cartItemId).update({
        'quantity': quantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('✅ Quantity updated: $cartItemId -> $quantity');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating quantity: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> toggleSelection(
    String userId,
    String cartItemId,
    bool isSelected,
  ) async {
    try {
      await _getUserCartCollection(userId).doc(cartItemId).update({
        'isSelected': isSelected,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('✅ Selection toggled: $cartItemId -> $isSelected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling selection: $e');
      }
      rethrow;
    }
  }

  @override
  Future<int> getCartItemCount(String userId) async {
    try {
      final snapshot = await _getUserCartCollection(userId).get();
      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cart count: $e');
      }
      return 0;
    }
  }

  @override
  Future<bool> isProductInCart(String userId, String productId) async {
    try {
      final snapshot =
          await _getUserCartCollection(
            userId,
          ).where('productId', isEqualTo: productId).get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking product in cart: $e');
      }
      return false;
    }
  }

  /// Remove selected items from cart (after order placement)
  Future<void> removeSelectedItems(String userId) async {
    try {
      final selectedItems =
          await _getUserCartCollection(
            userId,
          ).where('isSelected', isEqualTo: true).get();

      final batch = _firestore.batch();

      for (var doc in selectedItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Selected items removed from cart');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing selected items: $e');
      }
      rethrow;
    }
  }
}
