import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Ссылка на активный абонемент (ID документа в коллекции subscriptions)
  final String? activeSubscriptionId;

  UserProfile({
    required this.uid,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.activeSubscriptionId,
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
      activeSubscriptionId: _parseString(data['activeSubscriptionId']),
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
      if (activeSubscriptionId != null)
        'activeSubscriptionId': activeSubscriptionId,
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

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? activeSubscriptionId,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeSubscriptionId: activeSubscriptionId ?? this.activeSubscriptionId,
    );
  }

  @override
  String toString() {
    return 'UserProfile($uid, $fullName, $email, $activeSubscriptionId)';
  }
}