import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;

  final String userId;

  final String tariffId;

  final DateTime startDate;

  final DateTime endDate;

  final int totalSessions;

  final int remainingSessions;

  final bool isActive;

  final DateTime createdAt;

  final DateTime? lastUsed;

  const Subscription({
    required this.id,
    required this.userId,
    required this.tariffId,
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.remainingSessions,
    required this.isActive,
    required this.createdAt,
    this.lastUsed,
  });

  /// Конвертирует модель в Map для записи в Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tariffId': tariffId,
      'startDate': startDate,
      'endDate': endDate,
      'totalSessions': totalSessions,
      'remainingSessions': remainingSessions,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastUsed': lastUsed,
    };
  }

  /// Создает модель из документа Firestore
  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      userId: data['userId'] as String,
      tariffId: data['tariffId'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalSessions: data['totalSessions'] as int,
      remainingSessions: data['remainingSessions'] as int,
      isActive: data['isActive'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUsed: data['lastUsed'] != null
          ? (data['lastUsed'] as Timestamp).toDate()
          : null,
    );
  }

  /// Создает копию модели с измененными полями
  Subscription copyWith({
    String? id,
    String? userId,
    String? tariffId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalSessions,
    int? remainingSessions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastUsed,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tariffId: tariffId ?? this.tariffId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalSessions: totalSessions ?? this.totalSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// Проверяет, действителен ли абонемент на текущую дату
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        remainingSessions > 0;
  }

  /// Возвращает оставшееся количество дней действия
  int get remainingDays {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  @override
  String toString() {
    return 'Subscription('
        'id: $id, '
        'userId: $userId, '
        'tariffId: $tariffId, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'totalSessions: $totalSessions, '
        'remainingSessions: $remainingSessions, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'lastUsed: $lastUsed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subscription &&
        other.id == id &&
        other.userId == userId &&
        other.tariffId == tariffId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalSessions == totalSessions &&
        other.remainingSessions == remainingSessions &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      tariffId,
      startDate,
      endDate,
      totalSessions,
      remainingSessions,
      isActive,
      createdAt,
      lastUsed,
    );
  }
}