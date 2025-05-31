import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool? emailVerified;

  UserProfile({
    required this.uid,
    required this.fullName,
    this.email,
    this.photoUrl,
    this.createdAt,
    this.emailVerified,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      fullName: data['fullName'] ?? 'Без имени',
      email: data['email'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt']?.toDate(),
      emailVerified: data['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'emailVerified': emailVerified ?? false,
    };
  }
}