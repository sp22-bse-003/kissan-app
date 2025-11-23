import 'package:kissan/core/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts({
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? query,
  });
  Future<Product> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
