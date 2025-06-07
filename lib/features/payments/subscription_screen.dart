import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/data/models/subscription.dart';
import 'package:gladiatorapp/core/services/subscription_service.dart';
import 'package:logger/logger.dart';

enum SubscriptionState { loading, active, inactive, error }

class SubscriptionScreen extends StatefulWidget {


  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with WidgetsBindingObserver {
  Tariff? _selectedTariff;
  final Logger _logger = Logger();
  late Future<List<Tariff>> _tariffsFuture;
  SubscriptionState _state = SubscriptionState.loading;
  Timer? _paymentStatusTimer;
  bool _isProcessingPayment = false;

  // Цвета остаются постоянными в обеих темах
  final Color primaryColor = const Color(0xFFE53935); // Красный
  final Color successColor = const Color(0xFF4CAF50); // Зеленый
  final Color cardSelectedBorderColor = const Color(0xFFE53935); // Красный
  final Color cardUnselectedBorderColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScreen();
  }

  Future<void> _initScreen() async {
    await _checkSubscriptionStatus();
    _loadTariffs();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      setState(() => _state = SubscriptionState.loading);
      final subscription = await SubscriptionService.fetchSubscription();

      if (!mounted) return;

      if (_hasActiveSubscription(subscription)) {
        setState(() => _state = SubscriptionState.active);
      } else {
        setState(() => _state = SubscriptionState.inactive);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = SubscriptionState.error);
      }
    }
  }

  Future<void> _loadTariffs() async {
    _tariffsFuture = SubscriptionService.fetchTariffs();
    if (_state == SubscriptionState.inactive && mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isProcessingPayment) {
      _verifyPaymentStatus();
    }
  }

  Future<void> _verifyPaymentStatus() async {
    if (!mounted || _state == SubscriptionState.active) return;

    setState(() => _isProcessingPayment = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      final subscription = await SubscriptionService.fetchSubscription();

      if (!mounted) return;

      if (_hasActiveSubscription(subscription)) {
        setState(() {
          _state = SubscriptionState.active;
          _isProcessingPayment = false;
        });
        _showPaymentSuccessDialog();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isProcessingPayment = false);
        _showPaymentNotCompletedDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        _showErrorDialog('Ошибка', 'Не удалось проверить статус платежа');
      }
    }
  }

  bool _hasActiveSubscription(Subscription? subscription) {
    return subscription?.isValid ?? false;
  }

  Future<void> _onPayNowPressed() async {
    if (_selectedTariff == null || !mounted) return;

    setState(() => _isProcessingPayment = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );

    try {
      final response = await SubscriptionService.createPayment(_selectedTariff!);
      if (!mounted) return;

      final confirmationUrl = response['payment']['confirmation']['confirmation_url'] as String;
      Navigator.of(context).pop();

      final launched = await SubscriptionService.launchPayment(confirmationUrl);
      if (!launched && mounted) {
        setState(() => _isProcessingPayment = false);
        _showErrorDialog('Ошибка', 'Не удалось открыть страницу оплаты');
        return;
      }

      _startPaymentStatusChecker();
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        Navigator.of(context).pop();
        _showErrorDialog('Ошибка платежа', e.toString());
      }
    }
  }

  void _startPaymentStatusChecker() {
    const interval = Duration(seconds: 5);
    const maxAttempts = 12;
    int attempts = 0;

    Timer.periodic(interval, (timer) async {
      if (!mounted || _state == SubscriptionState.active || attempts >= maxAttempts) {
        timer.cancel();
        if (attempts >= maxAttempts && mounted) {
          final subscription = await SubscriptionService.fetchSubscription();
          if (!_hasActiveSubscription(subscription)) {
            setState(() => _isProcessingPayment = false);
            _showPaymentNotCompletedDialog();
          }
        }
        return;
      }

      attempts++;
      try {
        final subscription = await SubscriptionService.fetchSubscription();
        if (_hasActiveSubscription(subscription)) {
          timer.cancel();
          if (mounted) {
            setState(() {
              _state = SubscriptionState.active;
              _isProcessingPayment = false;
            });
            _showPaymentSuccessDialog();
            Navigator.of(context).pop(true);
          }
        }
      } catch (e) {
        debugPrint('Ошибка проверки статуса: $e');
      }
    });
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(title: Text('Абонементы')),
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Абонементы'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 60,
              color: primaryColor, // Красная галочка
            ),
            const SizedBox(height: 20),
            Text(
              'У вас активный абонемент!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Красная кнопка
              ),
              child: const Text(
                'Вернуться',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(title: Text('Абонементы')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Ошибка загрузки данных',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Красная кнопка
              ),
              child: const Text(
                'Повторить',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTariffsView() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Абонементы',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Tariff>>(
        future: _tariffsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorView();
          }

          final tariffs = snapshot.data ?? [];
          if (tariffs.isEmpty) {
            return Center(
              child: Text(
                'Нет доступных тарифов',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            );
          }

          return _buildTariffsListView(tariffs);
        },
      ),
    );
  }

  Widget _buildTariffsListView(List<Tariff> tariffs) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                'Здравствуйте!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Выберите подходящий абонемент',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tariffs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => _buildTariffCard(tariffs[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _onPayNowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Красная кнопка
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Купить сейчас',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTariffCard(Tariff tariff) {
    final isSelected = _selectedTariff?.id == tariff.id;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedTariff = tariff),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cardSelectedBorderColor : cardUnselectedBorderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tariff.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: primaryColor, // Красная галочка
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${tariff.price} ₽',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...tariff.features.map(
                  (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check,
                      size: 20,
                      color: successColor, // Зеленая галочка
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedTariff = tariff),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : theme.colorScheme.surfaceVariant,
                  side: BorderSide(
                    color: isSelected ? primaryColor : theme.dividerColor,
                  ),
                ),
                child: Text(
                  isSelected ? 'Выбрано' : 'Выбрать',
                  style: TextStyle(
                    color: isSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          'Успешно!',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          'Ваш абонемент активирован.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentNotCompletedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          'Платёж не завершён',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          'Проверьте историю платежей или попробуйте ещё раз.',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case SubscriptionState.loading:
        return _buildLoadingView();
      case SubscriptionState.active:
        return _buildActiveSubscriptionView();
      case SubscriptionState.inactive:
        return _buildTariffsView();
      case SubscriptionState.error:
        return _buildErrorView();
    }
  }
}