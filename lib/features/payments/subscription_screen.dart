import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:gladiatorapp/core/services/subscription_service.dart';

enum SubscriptionState { loading, active, inactive, error }

class SubscriptionScreen extends StatefulWidget {
  final UserProfile userProfile;

  const SubscriptionScreen({Key? key, required this.userProfile})
      : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  Tariff? _selectedTariff;
  late Future<List<Tariff>> _tariffsFuture;
  SubscriptionState _state = SubscriptionState.loading;
  StreamSubscription<Uri?>? _deepLinkSub;
  final _appLinks = AppLinks();
  Timer? _paymentStatusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScreen();
  }

  Future<void> _initScreen() async {
    await _checkInitialSubscription();
    _initDeepLinks();
  }

  Future<void> _checkInitialSubscription() async {
    try {
      if (_hasActiveSubscription(widget.userProfile)) {
        setState(() => _state = SubscriptionState.active);
      } else {
        _tariffsFuture = SubscriptionService.fetchTariffs();
        setState(() => _state = SubscriptionState.inactive);
      }
    } catch (e) {
      setState(() => _state = SubscriptionState.error);
    }
  }

  void _initDeepLinks() {
    _deepLinkSub?.cancel();
    _deepLinkSub = _appLinks.uriLinkStream.listen(_handleIncomingUri, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    _checkInitialDeepLink();
  }

  Future<void> _checkInitialDeepLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } catch (err) {
      debugPrint('Initial deep link error: $err');
    }
  }

  Future<void> _handleIncomingUri(Uri? uri) async {
    if (uri == null || !mounted) return;

    debugPrint('Received deep link: $uri');
    if (uri.scheme == 'gladiatorapp' && uri.host == 'payment') {
      final success = uri.queryParameters['success'];
      final cancelled = uri.queryParameters['cancelled'];

      if (success == 'true') {
        await _processSuccessfulPayment();
      } else if (cancelled == 'true') {
        _showPaymentCancelledDialog();
      } else {
        _showErrorDialog('Ошибка', 'Неизвестный статус платежа');
      }
    }
  }

  Future<void> _processSuccessfulPayment() async {
    try {
      setState(() => _state = SubscriptionState.loading);
      final freshProfile = await SubscriptionService.fetchUserProfile();

      if (!mounted) return;

      if (_hasActiveSubscription(freshProfile)) {
        setState(() => _state = SubscriptionState.active);
        _showPaymentSuccessDialog();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _state = SubscriptionState.inactive);
        _showErrorDialog('Ошибка', 'Подписка не активирована');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = SubscriptionState.error);
        _showErrorDialog('Ошибка', 'Не удалось проверить статус подписки');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _paymentStatusTimer?.cancel();
      Future.delayed(const Duration(seconds: 1), _verifyPaymentStatus);
    }
  }

  Future<void> _verifyPaymentStatus() async {
    if (!mounted || _state == SubscriptionState.active) return;

    try {
      setState(() => _state = SubscriptionState.loading);
      final freshProfile = await SubscriptionService.fetchUserProfile();

      if (!mounted) return;

      if (_hasActiveSubscription(freshProfile)) {
        setState(() => _state = SubscriptionState.active);
        _showPaymentSuccessDialog();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _state = SubscriptionState.inactive);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = SubscriptionState.error);
      }
    }
  }

  bool _hasActiveSubscription(UserProfile profile) {
    return profile.activeTariffId != null;
  }

  Future<void> _onPayNowPressed() async {
    if (_selectedTariff == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final response = await SubscriptionService.createPayment(_selectedTariff!);
      if (!mounted) return;

      final confirmationUrl = response['payment']['confirmation']['confirmation_url'] as String;
      Navigator.of(context).pop();

      final launched = await SubscriptionService.launchPayment(confirmationUrl);
      if (!launched && mounted) {
        _showErrorDialog('Ошибка', 'Не удалось открыть страницу оплаты');
        return;
      }

      _startPaymentStatusTimer();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog('Ошибка платежа', e.toString());
      }
    }
  }

  void _startPaymentStatusTimer() {
    _paymentStatusTimer?.cancel();
    _paymentStatusTimer = Timer(const Duration(minutes: 2), () async {
      if (!mounted || _state == SubscriptionState.active) return;

      _showErrorDialog(
          'Внимание',
          'Платёж не завершён. Проверьте историю платежей или попробуйте ещё раз'
      );
    });
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    _deepLinkSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Регионы UI построения
  Widget _buildLoadingView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Абонементы')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildActiveSubscriptionView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Абонементы'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'У вас активный абонемент,\n${widget.userProfile.fullName ?? "пользователь"}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Вернуться'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Абонементы')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Ошибка загрузки данных',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initScreen,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTariffsView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Абонементы',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Tariff>>(
        future: _tariffsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView();
          }

          final tariffs = snapshot.data ?? [];
          if (tariffs.isEmpty) {
            return const Center(child: Text('Нет доступных тарифов'));
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
                'Здравствуйте, ${widget.userProfile.fullName ?? "пользователь"}!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Выберите подходящий абонемент',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
              onPressed: _selectedTariff == null ? null : _onPayNowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.red.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
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
    return GestureDetector(
      onTap: () => setState(() => _selectedTariff = tariff),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey.shade300,
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
                    color: isSelected ? Colors.red : Colors.black,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${tariff.price} ₽',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ...tariff.features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedTariff = tariff),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
                  side: BorderSide(
                    color: isSelected ? Colors.red : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  isSelected ? 'Выбрано' : 'Выбрать',
                  style: TextStyle(
                    color: isSelected ? Colors.red : Colors.black87,
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
        title: const Text('Успешно!'),
        content: const Text('Ваш абонемент активирован.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentCancelledDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Отменено'),
        content: const Text('Платёж был отменён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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