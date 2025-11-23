import 'package:flutter/material.dart';
import 'knowledge_hub_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LikedArticlesScreen extends StatefulWidget {
  const LikedArticlesScreen({super.key});

  @override
  State<LikedArticlesScreen> createState() => _LikedArticlesScreenState();
}

class _LikedArticlesScreenState extends State<LikedArticlesScreen> {
  final List<Map<String, dynamic>> allArticles = [
    {
      'id': 1,
      'title': 'Benefits of Urea',
      'image': 'assets/images/tea_field.jpg',
      'shortDescription': 'Urea is one of the most widely used nitrogen fertilizers in agriculture. It promotes rapid plant growth and enhances crop yield by providing a rich nitrogen source. Easy to apply and highly soluble, urea is suitable for various soil types.',
      'fullDescription': 'Urea is one of the most widely used nitrogen fertilizers in agriculture. It promotes rapid plant growth and enhances crop yield by providing a rich nitrogen source. Easy to apply and highly soluble, urea is suitable for various soil types. It supports the development of green, leafy crops, especially in cereals like wheat and rice. Urea is also cost-effective, making it ideal for both small and large-scale farmers. Regular use improves soil fertility when applied correctly and in balanced amounts. However, overuse of urea can lead to soil acidification and nutrient imbalance, so proper guidance and dosage are essential. Integrating it with organic matter or other balanced fertilizers can enhance its effectiveness while protecting soil health. It also helps reduce nitrogen loss through leaching or volatilization when applied at the right time and in suitable weather conditions. Farmers practicing precision agriculture can optimize application techniques like fertigation for better efficiency. Specialized formulations of urea are available as part of "smart" fertilizers to further maximize benefits; farmers can consult agricultural experts for tailored advice.',
      'isLiked': true,
    },
    {
      'id': 2,
      'title': 'Pest Control Strategies',
      'image': 'assets/images/wheat_field.jpg',
      'shortDescription': 'Effective pest control is crucial for protecting crops from damage and ensuring high yields. Integrated Pest Management (IPM) combines various methods to minimize pest populations while reducing environmental impact.',
      'fullDescription': 'Integrated Pest Management (IPM) is a comprehensive approach to pest control that combines biological, cultural, physical, and chemical tools in a way that minimizes economic, health, and environmental risks. Key strategies include monitoring pest populations, using pest-resistant crop varieties, encouraging natural predators, practicing crop rotation, and applying pesticides only when necessary and in targeted ways. This holistic approach helps maintain ecosystem balance and reduces reliance on synthetic pesticides, leading to healthier crops and a more sustainable agricultural system.',
      'isLiked': true,
    },
    {
      'id': 3,
      'title': 'Modern Irrigation Techniques',
      'image': 'assets/images/tractor.jpg',
      'shortDescription': 'Modern irrigation techniques, such as drip irrigation and sprinkler systems, offer efficient water usage for crop cultivation, minimizing water waste and maximizing resource allocation.',
      'fullDescription': 'Modern irrigation techniques play a vital role in sustainable agriculture by optimizing water usage and improving crop yields. Drip irrigation delivers water directly to the plant roots, reducing evaporation and runoff, making it highly efficient for water-scarce regions. Sprinkler systems provide uniform water distribution over larger areas, suitable for various crops. Center pivot irrigation systems offer automated watering for extensive fields, saving labor and water. These advanced methods help farmers achieve higher productivity with less water, contributing to both economic and environmental sustainability. Proper planning and maintenance are essential for maximizing the benefits of these systems.',
      'isLiked': false,
    },
    {
      'id': 4,
      'title': 'Organic Farming Principles',
      'image': 'assets/images/tea_field.jpg',
      'shortDescription': 'Organic farming relies on ecological processes, biodiversity, and cycles adapted to local conditions, rather than the use of synthetic fertilizers and pesticides.',
      'fullDescription': 'Organic farming is a method of crop and livestock production that involves much more than choosing not to use pesticides, fertilizers, genetically modified organisms, antibiotics and growth hormones. The primary goal of organic agriculture is to optimize the health and productivity of interdependent communities of soil life, plants, animals and people. Organic farming principles include enhancing soil fertility, promoting biodiversity, conserving natural resources, and minimizing pollution. It emphasizes sustainable practices that build soil health and foster ecological balance.',
      'isLiked': true,
    },
  ];

  late List<Map<String, dynamic>> likedArticles;

  @override
  void initState() {
    super.initState();
    _filterLikedArticles();
  }

  void _filterLikedArticles() {
    likedArticles = allArticles.where((article) => article['isLiked'] == true).toList();
  }

  Future<void> _showUnlikeConfirmationDialog(BuildContext context, Map<String, dynamic> article) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove from Liked?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove "${article['title']}" from your liked articles?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  article['isLiked'] = false;
                  _filterLikedArticles();
                });
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${article['title']}" removed from liked.')),
                );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Liked Articles',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final article = likedArticles[index];
                  return _buildArticleCard(article, context);
                },
                childCount: likedArticles.length,
              ),
            ),
          ),
          if (likedArticles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No liked articles yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    Text(
                      'Like some articles in Knowledge Hub to see them here!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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

  Widget _buildArticleCard(Map<String, dynamic> article, BuildContext context) {
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
                child: Image.asset(
                  article['image'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: _buildIconButton(
                  Icons.favorite,
                      () {
                    _showUnlikeConfirmationDialog(context, article);
                  },
                  article['isLiked'] ? Color(0xFF22C922) : Colors.black,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: _buildIconButton(
                  Icons.volume_up,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Text-to-speech for article')),
                    );
                  },
                  Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'],
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article['shortDescription'],
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
                        builder: (context) => KnowledgeHubDetailsScreen(article: article),
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
