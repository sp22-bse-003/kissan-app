import 'package:kissan/core/models/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> fetchArticles({String? query});
  Future<void> toggleLike(String id, bool isLiked);
  Future<Article> addArticle(Article article);
  Future<void> updateArticle(Article article);
  Future<void> deleteArticle(String id);
}
