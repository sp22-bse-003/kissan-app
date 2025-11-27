import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/repositories/article_repository.dart';
import 'package:kissan/data/local/local_article_repository.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';

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

    final l10n = AppLocalizations.of(_context)!;
    final seeds = [
      Article(
        id: '1',
        title: l10n.articleUreaTitle,
        image: 'assets/images/tea_field.jpg',
        shortDescription: l10n.articleUreaShort,
        fullDescription: l10n.articleUreaFull,
      ),
      Article(
        id: '2',
        title: l10n.articleUreaTitle,
        image: 'assets/images/wheat_field.jpg',
        shortDescription: l10n.articleUreaShort,
        fullDescription: l10n.articleUreaFull,
      ),
      Article(
        id: '3',
        title: l10n.articleUreaTitle,
        image: 'assets/images/tractor.jpg',
        shortDescription: l10n.articleUreaShort,
        fullDescription: l10n.articleUreaFull,
      ),
    ];

    final batch = _db.batch();
    for (final a in seeds) {
      final ref = _db.collection(_collection).doc(a.id);
      batch.set(ref, a.toMap());
    }
    await batch.commit();
  }

  @override
  Future<List<Article>> fetchArticles({String? query}) async {
    try {
      await _ensureSeeded();

      // Fetch user's liked article IDs
      final user = FirebaseAuth.instance.currentUser;
      Set<String> likedIds = {};
      if (user != null) {
        final userLikesDoc =
            await _db.collection('user_liked_articles').doc(user.uid).get();
        if (userLikesDoc.exists) {
          likedIds =
              (userLikesDoc.data()?['articleIds'] as List<dynamic>?)
                  ?.cast<String>()
                  .toSet() ??
              {};
        }
      }

      Query<Map<String, dynamic>> q = _db.collection(_collection);
      if (query != null && query.trim().isNotEmpty) {
        // Simple contains filter is not supported server-side without indexing; fetch client-side for PoC.
        final res = await q.get();
        final all =
            res.docs.map((d) {
              final article = Article.fromMap(d.data());
              article.isLiked = likedIds.contains(article.id);
              return article;
            }).toList();
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
        return res.docs.map((d) {
          final article = Article.fromMap(d.data());
          article.isLiked = likedIds.contains(article.id);
          return article;
        }).toList();
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userLikesRef = _db.collection('user_liked_articles').doc(user.uid);

      if (isLiked) {
        // Add article to liked list
        await userLikesRef.set({
          'articleIds': FieldValue.arrayUnion([id]),
        }, SetOptions(merge: true));
      } else {
        // Remove article from liked list
        await userLikesRef.set({
          'articleIds': FieldValue.arrayRemove([id]),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Silently ignore in this PoC; UI already updated optimistically.
    }
  }

  @override
  Future<List<Article>> fetchLikedArticles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      await _ensureSeeded();

      // Get user's liked article IDs
      final userLikesDoc =
          await _db.collection('user_liked_articles').doc(user.uid).get();
      if (!userLikesDoc.exists) return [];

      final likedIds = List<String>.from(
        userLikesDoc.data()?['articleIds'] ?? [],
      );
      if (likedIds.isEmpty) return [];

      // Fetch all liked articles
      final articlesSnapshot =
          await _db
              .collection(_collection)
              .where(FieldPath.documentId, whereIn: likedIds)
              .get();
      return articlesSnapshot.docs
          .map((d) => Article.fromMap(d.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch liked articles: $e');
      }
      return [];
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
