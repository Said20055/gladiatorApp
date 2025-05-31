// lib/data/models/tariff.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Tariff {
  final String id;
  final String title;
  final int price;           // Цена в рублях, например 3000 или 3500
  final List<String> features;
  final bool isBest;         // Флаг для отметки «Best Value» (при необходимости)

  Tariff({
    required this.id,
    required this.title,
    required this.price,
    required this.features,
    this.isBest = false,
  });

  /// Создает объект Tariff из документа Firestore
  factory Tariff.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tariff(
      id: doc.id,
      title: data['title'] as String?        ?? '',
      price: data['price'] as int?            ?? 0,
      features: List<String>.from(data['features'] as List<dynamic>? ?? []),
      isBest: data['isBest'] as bool?         ?? false,
    );
  }

  /// Преобразует объект Tariff в Map<String, dynamic> для записи в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'price': price,
      'features': features,
      'isBest': isBest,
    };
  }
}
