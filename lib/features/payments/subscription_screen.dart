import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/features/payments/payment_webview_screen.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Tariff? _selectedTariff;
  late Future<List<Tariff>> _tariffsFuture;

  @override
  void initState() {
    super.initState();
    _tariffsFuture = _fetchTariffs(); // Сохраняем Future
  }

  Future<List<Tariff>> _fetchTariffs() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('tariffs').get();
    return querySnapshot.docs.map((doc) => Tariff.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Абонементы',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Ошибка загрузки тарифов'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tariffsFuture = _fetchTariffs(); // повторная загрузка
                      });
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final List<Tariff> tariffs = snapshot.data ?? [];
          if (tariffs.isEmpty) {
            return const Center(child: Text('Тарифы не найдены'));
          }

          return _buildSubscriptionContent(tariffs);
        },
      ),
    );
  }

  Widget _buildSubscriptionContent(List<Tariff> tariffs) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: const [
              Text(
                'Разблокировать функции и купить абонемент',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Получить доступ ко всем тренировкам, персональным планам и поход в зал.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tariffs.length + 1,
            itemBuilder: (context, index) {
              if (index < tariffs.length) {
                final tariff = tariffs[index];
                return Column(
                  children: [
                    _buildTariffCard(tariff),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                return const SizedBox(height: 48);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTariffCard(Tariff tariff) {
    final bool isSelected = _selectedTariff?.id == tariff.id;

    return Stack(
      children: [
        Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.red,
                      size: 20,
                    ),
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
              Column(
                children: tariff.features
                    .map(
                      (feat) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTariff = tariff;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                    isSelected ? Colors.red.shade50 : Colors.grey.shade100,
                    side: BorderSide(
                      color: isSelected ? Colors.red : Colors.grey.shade400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isSelected ? 'Выбрано' : 'Выбрать',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (tariff.isBest)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                'Лучшее предложение',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onPayNowPressed() async {
    if (_selectedTariff == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('https://yoocassa.onrender.com/api/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'value': _selectedTariff!.price,
          'orderID': DateTime.now().millisecondsSinceEpoch.toString(),
          'userUID': FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
        }),
      );

      Navigator.of(context).pop();

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final confirmationUrl =
        responseData['payment']?['confirmation']?['confirmation_url'];

        if (confirmationUrl != null) {
          _openPaymentWebView(confirmationUrl);
        } else {
          _showErrorDialog('Ошибка платежа', 'Не получен URL для оплаты');
        }
      } else {
        _showErrorDialog(
          'Ошибка ${response.statusCode}',
          responseData['error'] ?? 'Неизвестная ошибка сервера',
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog('Ошибка', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openPaymentWebView(String url) async {
    final paymentSuccess = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentWebViewScreen(paymentUrl: url),
      ),
    );

    if (paymentSuccess == true) {
      _updateSubscriptionStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оплата прошла успешно!')),
      );
    }
  }

  Future<void> _updateSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'hasPremium': true,
        'subscriptionEnd': DateTime.now().add(const Duration(days: 30)),
      });
    }
  }
}
