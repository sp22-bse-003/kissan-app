import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/l10n/gen/app_localizations.dart';

class KnowledgeHubDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const KnowledgeHubDetailsScreen({super.key, required this.article});

  @override
  State<KnowledgeHubDetailsScreen> createState() =>
      _KnowledgeHubDetailsScreenState();
}

class _KnowledgeHubDetailsScreenState extends State<KnowledgeHubDetailsScreen> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.article['isLiked'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.article['title'] ?? 'No Title';
    final String fullDescription =
        widget.article['fullDescription'] ?? 'No Description';
    final String? imagePath = widget.article['image'];

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
            if (imagePath != null && imagePath.isNotEmpty)
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
          isLiked ? Icons.favorite : Icons.favorite,
          size: 19,
          color: isLiked ? Color(0xFF22C922) : Colors.black,
        ),
        onPressed: () {
          setState(() {
            isLiked = !isLiked;
            widget.article['isLiked'] = isLiked;
          });
        },
        padding: EdgeInsets.zero,
      ),
    );
  }
}
