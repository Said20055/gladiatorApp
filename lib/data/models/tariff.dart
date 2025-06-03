import 'package:cloud_firestore/cloud_firestore.dart';

class Tariff {
  final String id;
  final String title;
  final int price;                  // Цена в рублях
  final List<String> features;
  final bool isBest;

  final String duration;           // Новый параметр: период действия (например, "1 месяц")
  final int sessionCount;          // Новый параметр: кол-во тренировок (например, 12)

  Tariff({
    required this.id,
    required this.title,
    required this.price,
    required this.features,
    this.isBest = false,
    required this.duration,
    required this.sessionCount,
  });

  /// Создает объект Tariff из документа Firestore
  factory Tariff.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Tariff(
      id: doc.id,
      title: data['title'] as String? ?? '',
      price: data['price'] as int? ?? 0,
      features: List<String>.from(data['features'] as List<dynamic>? ?? []),
      isBest: data['isBest'] as bool? ?? false,
      duration: data['duration'] as String? ?? '1 месяц',
      sessionCount: data['sessionCount'] as int? ?? 0,

    );
  }

  /// Преобразует объект Tariff в Map<String, dynamic> для записи в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'price': price,
      'features': features,
      'isBest': isBest,
      'duration': duration,
      'sessionCount': sessionCount,
    };
  }
}
