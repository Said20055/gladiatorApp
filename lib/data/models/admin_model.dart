import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String email;
  final String role; // 'admin', 'manager'
  final List<String> permissions;

  AdminUser({
    required this.uid,
    required this.email,
    this.role = 'admin',
    this.permissions = const ['scan_qr', 'manage_users'],
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      email: data['email'],
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  bool get canScanQr => !permissions.contains('scan_qr');
}