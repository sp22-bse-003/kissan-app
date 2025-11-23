class Article {
  final String id;
  final String title;
  final String image;
  final String shortDescription;
  final String fullDescription;
  bool isLiked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.image,
    required this.shortDescription,
    required this.fullDescription,
    this.isLiked = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      fullDescription: map['fullDescription'] ?? '',
      isLiked: map['isLiked'] ?? false,
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map['createdAt'].millisecondsSinceEpoch,
              )
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map['updatedAt'].millisecondsSinceEpoch,
              )
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'image': image,
    'shortDescription': shortDescription,
    'fullDescription': fullDescription,
    'isLiked': isLiked,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}
