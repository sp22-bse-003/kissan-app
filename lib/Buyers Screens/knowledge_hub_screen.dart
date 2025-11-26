import 'package:flutter/material.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'knowledge_hub_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/repositories/article_repository.dart';

class KnowledgeHubScreen extends StatefulWidget {
  const KnowledgeHubScreen({super.key});

  @override
  State<KnowledgeHubScreen> createState() => _KnowledgeHubScreenState();
}

class _KnowledgeHubScreenState extends State<KnowledgeHubScreen> {
  late final ArticleRepository _repo;
  List<Article> _articles = const [];
  bool _loading = true;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize DI once we have context (for localized seed data in local repo)
    ServiceLocator.init(context);
    _repo = ServiceLocator.get<ArticleRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _repo.fetchArticles(query: _query);
    setState(() {
      _articles = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildSearchBar(),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final article = _articles[index];
                return _buildArticleCard(article, context);
              }, childCount: _articles.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) {
                _query = val;
                _load();
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHere,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const Icon(Icons.mic, color: Colors.black, size: 27),
          const SizedBox(width: 12),
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
                child: _buildArticleImage(article.image),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _buildIconButton(
                  Icons.favorite,
                  () async {
                    setState(() {
                      article.isLiked = !article.isLiked;
                    });
                    await _repo.toggleLike(article.id, article.isLiked);
                  },
                  article.isLiked ? const Color(0xFF22C922) : Colors.black,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildIconButton(Icons.volume_up, () {}, Colors.black),
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
                            (context) => KnowledgeHubDetailsScreen(
                              article: article.toMap(),
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.seeMore,
                      style: const TextStyle(
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

  Widget _buildArticleImage(String imageUrl) {
    // If empty, show placeholder
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        color: Colors.grey[200],
        child: const Icon(Icons.article, size: 60, color: Colors.grey),
      );
    }

    // If it's a Firebase Storage URL or any http URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF22C922),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading article image: $error');
          return Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 60, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image unavailable', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      );
    }

    // If it's an asset path
    return Image.asset(
      imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 180,
          color: Colors.grey[200],
          child: const Icon(Icons.article, size: 60, color: Colors.grey),
        );
      },
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
