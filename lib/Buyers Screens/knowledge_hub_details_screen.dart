import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';
import 'package:kissan/core/models/article.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:kissan/core/repositories/article_repository.dart';

class KnowledgeHubDetailsScreen extends StatefulWidget {
  final Article article;

  const KnowledgeHubDetailsScreen({super.key, required this.article});

  @override
  State<KnowledgeHubDetailsScreen> createState() =>
      _KnowledgeHubDetailsScreenState();
}

class _KnowledgeHubDetailsScreenState extends State<KnowledgeHubDetailsScreen> {
  late bool isLiked;
  bool _showTickAnimation = false;
  late final ArticleRepository _repo;

  @override
  void initState() {
    super.initState();
    isLiked = widget.article.isLiked;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = ServiceLocator.get<ArticleRepository>();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.article.title;
    final String fullDescription = widget.article.fullDescription;
    final String imagePath = widget.article.image;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.articleDetails,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath.isNotEmpty)
              Stack(
                children: [
                  Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  Positioned(top: 12, left: 12, child: _buildFavoriteButton()),
                ],
              )
            else
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)!.noImageAvailable),
                  ),
                  Positioned(top: 12, left: 12, child: _buildFavoriteButton()),
                ],
              ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                fullDescription,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _showTickAnimation ? Icons.check : Icons.add,
          size: 19,
          color: _showTickAnimation ? Color(0xFF22C922) : Colors.black,
        ),
        onPressed: () async {
          if (!isLiked && !_showTickAnimation) {
            // Show tick animation when adding to liked
            setState(() {
              _showTickAnimation = true;
            });
            // Save to Firebase
            await _repo.toggleLike(widget.article.id, true);
            await Future.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                _showTickAnimation = false;
                isLiked = true;
                widget.article.isLiked = true;
              });
            }
          } else if (isLiked && !_showTickAnimation) {
            // Already liked, remove from liked
            setState(() {
              isLiked = false;
              widget.article.isLiked = false;
            });
            // Remove from Firebase
            await _repo.toggleLike(widget.article.id, false);
          }
        },
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildArticleImage(String imageUrl) {
    // If it's a Firebase Storage URL or any http URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 250,
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
            height: 250,
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
      height: 250,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey[200],
          child: const Icon(Icons.article, size: 60, color: Colors.grey),
        );
      },
    );
  }
}
