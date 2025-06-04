import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Поля связанные с абонементом
  final String? activeTariffId;
  final String? activeTariffName;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final int? remainingSessions;
  final int? totalSessions;
  final String? paymentStatus;
  final String? lastPaymentId;
  final DateTime? lastPaymentDate;
  final bool? isSubscriptionActive;

  UserProfile({
    required this.uid,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.activeTariffId,
    this.activeTariffName,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.remainingSessions,
    this.totalSessions,
    this.paymentStatus,
    this.lastPaymentId,
    this.lastPaymentDate,
    this.isSubscriptionActive,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Document data is null');

    return UserProfile(
      uid: doc.id,
      fullName: _parseString(data['fullName'], fallback: 'Без имени'),
      email: _parseString(data['email']),
      phoneNumber: _parseString(data['phoneNumber']),
      photoUrl: _parseString(data['photoUrl']),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      activeTariffId: _parseString(data['activeTariffId']),
      activeTariffName: _parseString(data['activeTariffName']),
      subscriptionStartDate: _parseTimestamp(data['subscriptionStartDate']),
      subscriptionEndDate: _parseTimestamp(data['subscriptionEndDate']),
      remainingSessions: _parseInt(data['remainingSessions']),
      totalSessions: _parseInt(data['totalSessions']),
      paymentStatus: _parseString(data['paymentStatus']),
      lastPaymentId: _parseString(data['lastPaymentId']),
      lastPaymentDate: _parseTimestamp(data['lastPaymentDate']),
      isSubscriptionActive: _parseBool(data['isSubscriptionActive']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (activeTariffId != null) 'activeTariffId': activeTariffId,
      if (activeTariffName != null) 'activeTariffName': activeTariffName,
      if (subscriptionStartDate != null)
        'subscriptionStartDate': Timestamp.fromDate(subscriptionStartDate!),
      if (subscriptionEndDate != null)
        'subscriptionEndDate': Timestamp.fromDate(subscriptionEndDate!),
      if (remainingSessions != null) 'remainingSessions': remainingSessions,
      if (totalSessions != null) 'totalSessions': totalSessions,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (lastPaymentId != null) 'lastPaymentId': lastPaymentId,
      if (lastPaymentDate != null)
        'lastPaymentDate': Timestamp.fromDate(lastPaymentDate!),
      if (isSubscriptionActive != null)
        'isSubscriptionActive': isSubscriptionActive,
    };
  }

  // Вспомогательные методы парсинга
  static String? _parseString(dynamic value, {String? fallback}) {
    return value is String ? value : fallback;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    return value is Timestamp ? value.toDate() : null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    return value is int ? value : int.tryParse(value.toString());
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    return value is bool ? value : value.toString().toLowerCase() == 'true';
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? activeTariffId,
    String? activeTariffName,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    int? remainingSessions,
    int? totalSessions,
    String? paymentStatus,
    String? lastPaymentId,
    DateTime? lastPaymentDate,
    bool? isSubscriptionActive,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeTariffId: activeTariffId ?? this.activeTariffId,
      activeTariffName: activeTariffName ?? this.activeTariffName,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      lastPaymentId: lastPaymentId ?? this.lastPaymentId,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
    );
  }

  @override
  String toString() {
    return 'UserProfile($uid, $fullName, $email, $activeTariffId, $subscriptionEndDate)';
  }

  // Проверка активности абонемента
  bool get hasActiveSubscription {
    if (isSubscriptionActive != null) {
      return isSubscriptionActive!;
    }

    return subscriptionEndDate != null &&
        subscriptionEndDate!.isAfter(DateTime.now()) &&
        (remainingSessions ?? 0) > 0;
  }

  // Оставшееся время действия абонемента
  Duration? get remainingSubscriptionTime {
    if (subscriptionEndDate == null) return null;
    return subscriptionEndDate!.difference(DateTime.now());
  }
}