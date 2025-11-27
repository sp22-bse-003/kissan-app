import 'package:flutter/widgets.dart';
import 'package:kissan/core/repositories/article_repository.dart';
import 'package:kissan/core/repositories/product_repository.dart';
import 'package:kissan/core/repositories/cart_repository.dart';
import 'package:kissan/core/repositories/order_repository.dart';
import 'package:kissan/data/firebase/firestore_article_repository.dart';
import 'package:kissan/data/firebase/firestore_product_repository.dart';
import 'package:kissan/data/firebase/firestore_cart_repository.dart';
import 'package:kissan/data/firebase/firestore_order_repository.dart';
import 'package:kissan/core/services/image_upload_service.dart';
import 'package:kissan/core/services/cart_service.dart';
import 'package:kissan/core/services/order_service.dart';

class ServiceLocator {
  ServiceLocator._(this._builders);
  static ServiceLocator? _instance;

  final Map<Type, dynamic Function()> _builders;

  static void init(BuildContext context) {
    _instance = ServiceLocator._({
      ArticleRepository: () => FirestoreArticleRepository(context),
      ProductRepository: () => FirestoreProductRepository(),
      CartRepository: () => FirestoreCartRepository(),
      OrderRepository: () => FirestoreOrderRepository(),
      ImageUploadService: () => ImageUploadService(),
      CartService: () => CartService(),
      OrderService: () => OrderService(get<OrderRepository>()),
    });
  }

  static T get<T>() {
    final instance = _instance;
    if (instance == null) {
      throw StateError('ServiceLocator not initialized');
    }
    final builder = instance._builders[T];
    if (builder == null) {
      throw ArgumentError('No builder registered for type $T');
    }
    return builder() as T;
  }
}
