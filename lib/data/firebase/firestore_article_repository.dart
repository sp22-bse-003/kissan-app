import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/repositories/article_repository.dart';
import 'package:kissan/data/local/local_article_repository.dart';

class FirestoreArticleRepository implements ArticleRepository {
  final FirebaseFirestore _db;
  final BuildContext _context;

  FirestoreArticleRepository(this._context, {FirebaseFirestore? instance})
    : _db = instance ?? FirebaseFirestore.instance;

  static const String _collection = 'articles';

  Future<void> _ensureSeeded() async {
    // If there are already docs, assume seeded.
    final snapshot = await _db.collection(_collection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    // No auto-seeding with local assets.
    // Articles should be added via admin portal with Firebase Storage images.
    // This ensures all articles use proper Firebase Storage URLs.
    if (kDebugMode) {
      print(
        'No articles found in Firestore. Please add articles via admin portal.',
      );
    }
  }

  @override
  Future<List<Article>> fetchArticles({String? query}) async {
    try {
      await _ensureSeeded();

      Query<Map<String, dynamic>> q = _db.collection(_collection);
      if (query != null && query.trim().isNotEmpty) {
        // Simple contains filter is not supported server-side without indexing; fetch client-side for PoC.
        final res = await q.get();
        final all = res.docs.map((d) => Article.fromMap(d.data())).toList();
        final text = query.toLowerCase();
        return all
            .where(
              (a) =>
                  a.title.toLowerCase().contains(text) ||
                  a.shortDescription.toLowerCase().contains(text),
            )
            .toList();
      } else {
        final res = await q.get();
        return res.docs.map((d) => Article.fromMap(d.data())).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Firestore fetch failed, falling back to local: $e');
      }
      // Fall back to local seeded content so UI remains functional.
      final local = LocalArticleRepository(_context);
      return local.fetchArticles(query: query);
    }
  }

  @override
  Future<void> toggleLike(String id, bool isLiked) async {
    try {
      await _db.collection(_collection).doc(id).set({
        'isLiked': isLiked,
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently ignore in this PoC; UI already updated optimistically.
    }
  }

  @override
  Future<Article> addArticle(Article article) async {
    try {
      final docRef = await _db.collection(_collection).add({
        'title': article.title,
        'image': article.image,
        'shortDescription': article.shortDescription,
        'fullDescription': article.fullDescription,
        'isLiked': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final snapshot = await docRef.get();
      return Article.fromMap({...snapshot.data()!, 'id': snapshot.id});
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to add article: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateArticle(Article article) async {
    try {
      await _db.collection(_collection).doc(article.id).update({
        'title': article.title,
        'image': article.image,
        'shortDescription': article.shortDescription,
        'fullDescription': article.fullDescription,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to update article: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Failed to delete article: $e');
      }
      rethrow;
    }
  }
}
