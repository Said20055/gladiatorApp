import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/data/models/subscription.dart';
import 'package:gladiatorapp/core/services/auth_service.dart';
import 'package:gladiatorapp/features/home/profile/edit_profile_screen.dart';
import 'package:gladiatorapp/features/payments/subscription_screen.dart';
import 'package:gladiatorapp/core/views/qrgenerator_dialog.dart';
import 'package:gladiatorapp/features/payments/payment_history.dart';

import '../../../core/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  UserProfile? _userProfile;
  Tariff? _activeTariff;
  Subscription? _activeSubscription;
  bool _isLoading = true;
  bool _isSubscriptionLoading = false;

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (userDoc.exists) {
        _userProfile = UserProfile.fromFirestore(userDoc);

        if (_userProfile?.activeSubscriptionId != null) {
          await _fetchActiveSubscription(_userProfile!.activeSubscriptionId!);
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

  Future<void> _fetchActiveSubscription(String subscriptionId) async {
    setState(() => _isSubscriptionLoading = true);

    try {
      final subscriptionDoc = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(subscriptionId)
          .get();

      if (subscriptionDoc.exists) {
        _activeSubscription = Subscription.fromFirestore(subscriptionDoc);

        if (_activeSubscription?.tariffId != null) {
          await _fetchActiveTariff(_activeSubscription!.tariffId);
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки абонемента: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubscriptionLoading = false);
      }
    }
  }

  Future<void> _fetchActiveTariff(String tariffId) async {
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
    }
  }

  void _showQrDialog() {
    if (_userProfile == null || _activeSubscription == null) return;

    showDialog(
      context: context,
      builder: (context) => QrGeneratorDialog(
        userId: _userProfile!.uid,
        remainingSessions: _activeSubscription!.remainingSessions,
      ),
    ).then((_) => _fetchUserData());
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
      SnackBar(
        content: Text(
          'Письмо с изменением пароля отправлено на почту',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  Future<void> _logOut() async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          'Подтвердите выход',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          'Вы точно хотите выйти из аккаунта?',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Выйти',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
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
          builder: (_) => SubscriptionScreen(),
        ),
      ).then((_) => _fetchUserData());
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Профиль',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      )
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
          Icon(
            Icons.error_outline,
            size: 50,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка при загрузке профиля',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
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
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: _userProfile?.photoUrl != null
              ? NetworkImage(_userProfile!.photoUrl!)
              : null,
          child: _userProfile?.photoUrl == null
              ? Icon(
            Icons.person,
            size: 50,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile?.fullName ?? 'Пользователь',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile?.email ?? '',
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ],
    );
  }

  Widget _buildSubscriptionInfo() {
    if (_isSubscriptionLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    final hasActiveSubscription = _activeSubscription?.isValid ?? false;
    final subscriptionEndDate = _activeSubscription?.endDate;

    // Фиксированные цвета для состояний
    final activeColor = const Color(0xFF4CAF50); // Зеленый для активного абонемента
    final inactiveColor = Colors.grey; // Серый для неактивного

    final borderColor = hasActiveSubscription ? activeColor : inactiveColor;
    final textColor = hasActiveSubscription ? activeColor : inactiveColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      color: Theme.of(context).cardColor,
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
                    color: textColor,
                  ),
                ),
                if (hasActiveSubscription)
                  Chip(
                    label: Text(
                      _activeTariff?.title ?? 'Абонемент',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: activeColor, // Зеленый фон чипа
                  ),
              ],
            ),
            if (hasActiveSubscription) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'Срок действия:',
                '${_formatDate(_activeSubscription?.startDate)} - ${_formatDate(subscriptionEndDate)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Осталось тренировок:',
                '${_activeSubscription?.remainingSessions}/${_activeSubscription?.totalSessions}',
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
                onPressed: hasActiveSubscription
                    ? _showQrDialog
                    : _navigateToSubscription,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderColor),
                  backgroundColor: hasActiveSubscription
                      ? activeColor.withOpacity(0.1)
                      : null, // Слегка зеленый фон для активного
                ),
                child: Text(
                  hasActiveSubscription ? 'Показать QR-код' : 'Купить абонемент',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
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
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
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
            },
          ),
        ],
      ),
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
          leading: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(
            title,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _logOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
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