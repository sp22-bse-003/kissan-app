import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kissan/core/models/product.dart';
import 'package:kissan/core/repositories/product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _db;
  static const String _collection = 'products';

  FirestoreProductRepository({FirebaseFirestore? instance})
    : _db = instance ?? FirebaseFirestore.instance;

  @override
  Future<List<Product>> fetchProducts({
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? query,
  }) async {
    try {
      // For PoC, read all and filter client-side to avoid complex indexes.
      final snap = await _db.collection(_collection).get();
      var products =
          snap.docs.map((d) => Product.fromMap(d.data(), id: d.id)).toList();

      if (category != null && category.isNotEmpty) {
        products =
            products
                .where(
                  (p) => p.category.toLowerCase() == category.toLowerCase(),
                )
                .toList();
      }
      if (city != null && city.isNotEmpty && city != 'All Cities') {
        products =
            products
                .where(
                  (p) => (p.sellerLocation ?? '').toLowerCase().contains(
                    city.toLowerCase(),
                  ),
                )
                .toList();
      }
      if (minPrice != null) {
        products = products.where((p) => p.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.price <= maxPrice).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        products =
            products
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(q) ||
                      p.description.toLowerCase().contains(q),
                )
                .toList();
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('fetchProducts Firestore failed: $e');
      }
      return [];
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    try {
      final now = DateTime.now();
      final productWithTimestamps = product.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      final ref = await _db
          .collection(_collection)
          .add(productWithTimestamps.toMap());
      return productWithTimestamps.copyWith(id: ref.id);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('addProduct Firestore failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError('Product id is required for update');
    }
    try {
      final productWithUpdatedTime = product.copyWith(
        updatedAt: DateTime.now(),
      );
      await _db
          .collection(_collection)
          .doc(product.id)
          .set(productWithUpdatedTime.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('updateProduct Firestore failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('deleteProduct Firestore failed: $e');
      }
      rethrow;
    }
  }
}
