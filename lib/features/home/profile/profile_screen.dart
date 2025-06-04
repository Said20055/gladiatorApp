import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';
import 'package:gladiatorapp/features/home/profile//edit_profile_screen.dart';
import 'package:gladiatorapp/features/payments/subscription_screen.dart';
import 'package:intl/intl.dart';

import '../../payments/payment_history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  UserProfile? _userProfile;
  Tariff? _activeTariff;
  bool _isLoading = true;
  bool _isSubscriptionLoading = false;

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      // Загружаем профиль пользователя
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (userDoc.exists) {
        _userProfile = UserProfile.fromFirestore(userDoc);

        // Если есть активный абонемент, загружаем его данные
        if (_userProfile?.activeTariffId != null) {
          await _fetchActiveTariff(_userProfile!.activeTariffId!);
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchActiveTariff(String tariffId) async {
    setState(() => _isSubscriptionLoading = true);

    try {
      final tariffDoc = await FirebaseFirestore.instance
          .collection('tariffs')
          .doc(tariffId)
          .get();

      if (tariffDoc.exists) {
        _activeTariff = Tariff.fromFirestore(tariffDoc);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки тарифа: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubscriptionLoading = false);
      }
    }
  }

  void _redirectToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _editProfile() async {
    if (_userProfile == null) return;

    final updatedProfile = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialProfile: _userProfile!),
      ),
    );

    if (updatedProfile != null && mounted) {
      setState(() => _userProfile = updatedProfile);
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

  void _navigateToSubscription() {
    if (_userProfile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubscriptionScreen(userProfile: _userProfile!),
        ),
      ).then((_) => _fetchUserData()); // Обновляем данные после возврата
    }
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? DateFormat('dd.MM.yyyy').format(date)
        : 'Не указана';
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
          : _userProfile == null
          ? _buildErrorState()
          : _buildProfileContent(),
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
            onPressed: _fetchUserData,
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserHeader(),
          const SizedBox(height: 32),
          _buildSubscriptionInfo(),
          const SizedBox(height: 24),
          _buildProfileOptions(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _userProfile?.photoUrl != null
              ? NetworkImage(_userProfile!.photoUrl!)
              : null,
          child: _userProfile?.photoUrl == null
              ? const Icon(Icons.person, size: 50)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile?.fullName ?? 'Пользователь',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile?.email ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSubscriptionInfo() {
    if (_isSubscriptionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasActiveSubscription = _userProfile?.activeTariffId != null;
    final subscriptionEndDate = _userProfile?.subscriptionEndDate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasActiveSubscription ? Colors.green : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasActiveSubscription
                      ? 'Абонемент активен'
                      : 'Нет активного абонемента',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasActiveSubscription ? Colors.green : Colors.grey,
                  ),
                ),
                if (hasActiveSubscription)
                  Chip(
                    label: Text(
                      _activeTariff?.title ?? 'Абонемент',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
            if (hasActiveSubscription) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Срок действия:',
                '${_formatDate(_userProfile?.subscriptionStartDate)} - ${_formatDate(subscriptionEndDate)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Тип абонемента:',
                _activeTariff?.duration ?? '1 месяц',
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _navigateToSubscription,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: hasActiveSubscription
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                ),
                child: Text(
                  hasActiveSubscription
                      ? 'Продлить абонемент'
                      : 'Купить абонемент',
                  style: TextStyle(
                    color: hasActiveSubscription
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.edit,
          title: 'Редактировать профиль',
          onTap: _editProfile,
        ),
        _buildProfileOption(
          icon: Icons.lock,
          title: 'Изменить пароль',
          onTap: () => _changePassword(_userProfile?.email),
        ),
        _buildProfileOption(
          icon: Icons.credit_card,
          title: 'История платежей',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
            );
          }, // TODO: Реализовать экран истории платежей
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _logOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Выйти из аккаунта',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}