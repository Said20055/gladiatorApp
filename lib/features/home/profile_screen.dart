import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';
import 'package:gladiatorapp/features/home/edit_profile_screen.dart';
import 'package:gladiatorapp/features/payments/subscription_screen.dart'; // Импорт экрана редактирования

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  UserProfile? _cachedProfile; // Кешируем данные профиля
  bool _isLoading = false;

  Future<void> _fetchUserProfile() async {
    if (_cachedProfile != null) return; // Если данные уже есть, не запрашиваем снова

    setState(() => _isLoading = true);
    final uid = _currentUserId;
    if (uid == null) {
      _redirectToLogin();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        _cachedProfile = UserProfile.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _redirectToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _editProfile() async {
    if (_cachedProfile == null) return;

    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialProfile: _cachedProfile!),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() {
        _cachedProfile = updatedProfile; // Обновляем кеш
      });
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
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите выход'),
        content: const Text('Вы точно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogOut == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }


  void _sub() {
    if (_cachedProfile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubscriptionScreen(userProfile: _cachedProfile!),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Загружаем данные при инициализации
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cachedProfile == null
          ? _buildErrorState()
          : _buildProfileContent(_cachedProfile!),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: profile.photoUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  profile.fullName!,
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
              ],
            ),
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
          const SizedBox(height: 320),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _logOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
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