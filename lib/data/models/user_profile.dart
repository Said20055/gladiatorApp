import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool emailVerified;

  UserProfile({
    required this.uid,
    required this.fullName,
    this.email,
    this.photoUrl,
    this.createdAt,
    this.emailVerified = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) throw Exception('Document data is null');

    return UserProfile(
      uid: doc.id,
      fullName: _parseString(data['fullName'], fallback: 'Без имени'),
      email: _parseString(data['email']),
      photoUrl: _parseString(data['photoUrl']),
      createdAt: _parseTimestamp(data['createdAt']),
      emailVerified: data['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'emailVerified': emailVerified,
    };
  }

  // Вспомогательные методы для безопасного парсинга
  static String _parseString(dynamic value, {String fallback = ''}) {
    return value is String ? value : fallback;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    return value is Timestamp ? value.toDate() : null;
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    bool? emailVerified,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  String toString() {
    return 'UserProfile($uid, $fullName, $email)';
  }
}