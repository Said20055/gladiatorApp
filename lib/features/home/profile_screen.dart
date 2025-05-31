import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<UserProfile?> _fetchUserProfile(BuildContext context) async {
    final uid = _currentUserId;
    if (uid == null) {
      _redirectToLogin(context);
      return null;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
      return null;
    }
  }

  void _redirectToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<UserProfile?>(
        future: _fetchUserProfile(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState(context);
          }

          final profile = snapshot.data!;
          return _buildProfileContent(profile, context);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Ошибка при загрузке профиля'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_currentUserId != null) {
                _fetchUserProfile(context);
              } else {
                _redirectToLogin(context);
              }
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Абонемент активен',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildProfileOption(
            context,
            title: 'Редактировать профиль',
            onTap: () => _editProfile(context),
          ),
          _buildProfileOption(
            context,
            title: 'Изменить пароль',
            onTap: () => _changePassword(context, profile.email),
          ),
          _buildProfileOption(
            context,
            title: 'Выйти из аккаунта',
            onTap: () => _logOut(context),
          ),
          _buildProfileOption(
            context,
            title: 'Абонементы',
            onTap: () => _sub(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-profile');
  }

  void _changePassword(BuildContext context, String? email) {
    AuthService().resetPassword(email!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Письмо с изменением пароля отравлено на почту')),
    );
  }

  void _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }
  void _sub(BuildContext context) async {
    Navigator.of(context).pushNamed('/subscription');
  }
}
