import 'package:kissan/core/models/cart_item.dart';

/// Abstract repository interface for cart operations
abstract class CartRepository {
  /// Get all cart items for a specific user
  Stream<List<CartItemModel>> getCartItems(String userId);

  /// Add item to cart
  Future<void> addToCart(String userId, CartItemModel item);

  /// Update cart item (quantity, selection, etc.)
  Future<void> updateCartItem(String userId, CartItemModel item);

  /// Remove item from cart
  Future<void> removeFromCart(String userId, String cartItemId);

  /// Clear all items from cart
  Future<void> clearCart(String userId);

  /// Update item quantity
  Future<void> updateQuantity(String userId, String cartItemId, int quantity);

  /// Toggle item selection
  Future<void> toggleSelection(
    String userId,
    String cartItemId,
    bool isSelected,
  );

  /// Get cart item count
  Future<int> getCartItemCount(String userId);

  /// Check if product exists in cart
  Future<bool> isProductInCart(String userId, String productId);
}
