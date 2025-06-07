import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

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
    final logger = Logger();

    try {
      logger.d('🔧 Начало парсинга документа тарифа ${doc.id}');
      final data = doc.data() as Map<String, dynamic>? ?? {};

      logger.v('📝 Данные документа:');

      // Обработка features
      List<String> features = [];
      if (data['features'] is String) {
        logger.w('⚠️ Поле features является строкой, а не массивом');
        features = [data['features'] as String];
      } else if (data['features'] is List) {
        features = (data['features'] as List).map((e) => e.toString()).toList();
      }

      logger.d('✨ Создание объекта Tariff');
      final tariff = Tariff(
        id: doc.id,
        title: data['title'] as String? ?? '',
        price: data['price'] as int? ?? 0,
        features: features,
        isBest: data['isBest'] as bool? ?? false,
        duration: data['duration'] as String? ?? '1 месяц',
        sessionCount: data['sessionCount'] as int? ?? 0,
      );

      logger.v('🎉 Успешно создан Tariff: $tariff.toFirestore()');
      return tariff;
    } catch (e, stackTrace) {
      logger.e('💥 Ошибка при создании Tariff из документа ${doc.id}',
          error: e,
          stackTrace: stackTrace);
      rethrow;
    }
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
