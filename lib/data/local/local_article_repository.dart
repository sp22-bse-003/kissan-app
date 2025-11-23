import 'package:flutter/widgets.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/repositories/article_repository.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';

class LocalArticleRepository implements ArticleRepository {
  final BuildContext context;
  LocalArticleRepository(this.context);

  List<Article> _seed() {
    final l10n = AppLocalizations.of(context)!;
    return [
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
  }

  final Map<String, bool> _likes = {};

  @override
  Future<List<Article>> fetchArticles({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var articles = _seed();
    for (final a in articles) {
      a.isLiked = _likes[a.id] ?? false;
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      articles =
          articles
              .where(
                (a) =>
                    a.title.toLowerCase().contains(q) ||
                    a.shortDescription.toLowerCase().contains(q),
              )
              .toList();
    }
    return articles;
  }

  @override
  Future<void> toggleLike(String id, bool isLiked) async {
    _likes[id] = isLiked;
  }

  @override
  Future<Article> addArticle(Article article) async {
    // Local repository doesn't support persistence
    throw UnimplementedError('Add article not supported in local repository');
  }

  @override
  Future<void> updateArticle(Article article) async {
    // Local repository doesn't support persistence
    throw UnimplementedError(
      'Update article not supported in local repository',
    );
  }

  @override
  Future<void> deleteArticle(String id) async {
    // Local repository doesn't support persistence
    throw UnimplementedError(
      'Delete article not supported in local repository',
    );
  }
}
