import 'package:flutter/material.dart';
import 'knowledge_hub_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/repositories/article_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikedArticlesScreen extends StatefulWidget {
  const LikedArticlesScreen({super.key});

  @override
  State<LikedArticlesScreen> createState() => _LikedArticlesScreenState();
}

class _LikedArticlesScreenState extends State<LikedArticlesScreen> {
  late final ArticleRepository _repo;
  List<Article> likedArticles = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ServiceLocator.init(context);
    _repo = ServiceLocator.get<ArticleRepository>();
    _loadLikedArticles();
  }

  Future<void> _loadLikedArticles() async {
    setState(() => _loading = true);
    final articles = await _repo.fetchLikedArticles();
    setState(() {
      likedArticles = articles;
      _loading = false;
    });
  }

  Future<void> _showUnlikeConfirmationDialog(
    BuildContext context,
    Article article,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.red[700]),
              const SizedBox(width: 10),
              const Text('Remove from Liked?'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to remove "${article.title}" from your liked articles?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes, Remove'),
              onPressed: () async {
                // Toggle like in Firebase
                await _repo.toggleLike(article.id, false);
                // Reload liked articles
                await _loadLikedArticles();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '"${article.title}" removed from liked',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Liked Articles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF00E676)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _loading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                  strokeWidth: 3,
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final article = likedArticles[index];
                        return _buildArticleCard(article, context);
                      }, childCount: likedArticles.length),
                    ),
                  ),
                  if (likedArticles.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sentiment_dissatisfied,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No liked articles yet.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Like some articles in Knowledge Hub to see them here!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildArticleCard(Article article, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0xF2E7E3E3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child:
                    article.image.startsWith('http')
                        ? Image.network(
                          article.image,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : Image.asset(
                          article.image,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _buildIconButton(Icons.close, () {
                  _showUnlikeConfirmationDialog(context, article);
                }, Colors.red),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildIconButton(Icons.volume_up, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text-to-speech for article')),
                  );
                }, Colors.black),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.shortDescription,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                KnowledgeHubDetailsScreen(article: article),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'See More',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF22C922),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
