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
                  imagePath.startsWith('http')
                      ? Image.network(
                        imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey[300],
                              child: const Icon(Icons.article, size: 80),
                            ),
                      )
                      : Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.grey[300],
                              child: const Icon(Icons.article, size: 80),
                            ),
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
}
