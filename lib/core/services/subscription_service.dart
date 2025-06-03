import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SubscriptionService {
  static Future<List<Tariff>> fetchTariffs() async {
    final snapshot = await FirebaseFirestore.instance.collection('tariffs').get();
    return snapshot.docs.map((doc) => Tariff.fromFirestore(doc)).toList();
  }

  static Future<Map<String, dynamic>> createPayment(Tariff tariff) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final returnUrl = 'gladiatorapp://payment/return?user=$userId&success={success}';

    final response = await http.post(
      Uri.parse('https://yoocassa.onrender.com/api/payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'value': tariff.price,
        'orderID': DateTime.now().millisecondsSinceEpoch.toString(),
        'userUID': userId,
        'return_url': returnUrl,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment error: ${response.statusCode}');
    }
  }

  static Future<bool> launchPayment(String confirmationUrl) async {
    try {
      debugPrint('Attempting to launch URL: $confirmationUrl');

      final uri = Uri.parse(confirmationUrl);

      // Проверка валидности URL
      if (!uri.isAbsolute) {
        throw Exception('Invalid URL: $confirmationUrl');
      }

      // Дополнительная обработка для разных платформ
      if (Platform.isAndroid) {
        // Для Android пробуем разные варианты открытия
        try {
          return await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
        } catch (e) {
          debugPrint('Standard launch failed: $e');
          // Пробуем альтернативный метод
          if (await canLaunchUrl(uri)) {
            return await launchUrl(uri);
          }
        }
      } else if (Platform.isIOS) {
        // Специальная обработка для ЮMoney на iOS
        if (uri.host.contains('yoomoney')) {
          const yoomoneyAppUrl = 'yoomoney://';
          if (await canLaunchUrl(Uri.parse(yoomoneyAppUrl))) {
            return await launchUrl(Uri.parse(yoomoneyAppUrl));
          }
        }

        // Стандартный запуск для iOS
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      }

      // Общий fallback
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }

      debugPrint('Failed to launch URL: No activity found');
      return false;
    } catch (e) {
      debugPrint('Launch payment error: $e');
      return false;
    }
  }

  static Future<void> updateSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'hasPremium': true,
        'subscriptionEnd': DateTime.now().add(const Duration(days: 30)),
      });
    }
  }
}
