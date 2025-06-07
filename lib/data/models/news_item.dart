import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String title;
  final String description; // Краткое описание (как subtitle в текущем коде)
  final String fullDescription; // Добавляем поле для подробного описания
  final DateTime createdAt;
  final String? imageUrl;
  final String? category;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fullDescription,
    required this.createdAt,
    this.imageUrl,
    this.category,
  });
  factory NewsItem.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>; // Явное приведение типа
    return NewsItem(
      id: doc.id,
      title: data['title'] as String? ?? 'Без названия',
      description: data['description'] as String? ?? '',
      fullDescription: data['fullDescription'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      category: data['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fullDescription': fullDescription,
      'createdAt': Timestamp.fromDate(createdAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
    };
  }
}