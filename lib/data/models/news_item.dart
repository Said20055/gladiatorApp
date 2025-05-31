import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String imageUrl;
  final DateTime? createdAt; // Для сортировки

  NewsItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.createdAt,
  });

  // Метод для конвертации из Firestore
  factory NewsItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data()!;
    return NewsItem(
      id: snapshot.id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt']?.toDate(),
    );
  }

  // Метод для конвертации в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}