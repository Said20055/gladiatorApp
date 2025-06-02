import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';
import 'package:gladiatorapp/features/home/edit_profile_screen.dart'; // Импорт экрана редактирования

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<UserProfile?> _fetchUserProfile() async {
    final uid = _currentUserId;
    if (uid == null) {
      _redirectToLogin();
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

  void _redirectToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _editProfile() async {
    final profile = await _fetchUserProfile();
    if (profile == null) return;

    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialProfile: profile),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() {}); // Обновляем UI
    }
  }

  void _changePassword(String? email) {
    if (email == null) return;

    AuthService().resetPassword(email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Письмо с изменением пароля отправлено на почту')),
    );
  }

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _sub() {
    Navigator.of(context).pushNamed('/subscription');
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
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorState();
          }

          final profile = snapshot.data!;
          return _buildProfileContent(profile);
        },
      ),
    );
  }

  Widget _buildErrorState() {
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
                setState(() {}); // Перезагружаем данные
              } else {
                _redirectToLogin();
              }
            },
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
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
            title: 'Редактировать профиль',
            onTap: _editProfile,
          ),
          _buildProfileOption(
            title: 'Изменить пароль',
            onTap: () => _changePassword(profile.email),
          ),
          _buildProfileOption(
            title: 'Абонементы',
            onTap: _sub,
          ),
          _buildProfileOption(
            title: 'Выйти из аккаунта',
            onTap: _logOut,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({required String title, required VoidCallback onTap}) {
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
}