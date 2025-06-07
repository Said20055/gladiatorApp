import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'package:gladiatorapp/data/models/user_profile.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/subscription.dart';

class SubscriptionService {
  static final String BASE_URL = 'https://yoocassa.onrender.com';
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Не показывать количество методов в логе
      errorMethodCount: 5, // Количество методов при ошибке
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static Future<List<Tariff>> fetchTariffs() async {
    try {
      _logger.i('🔄 Начало загрузки тарифов из Firestore');

      final snapshot = await FirebaseFirestore.instance.collection('tariffs').get();
      _logger.i('📊 Получено ${snapshot.docs.length} тарифов');

      if (snapshot.docs.isEmpty) {
        _logger.w('⚠️ Коллекция tariffs пуста');
        return [];
      }

      final tariffs = <Tariff>[];
      for (final doc in snapshot.docs) {
        try {
          _logger.d('🔍 Обработка документа ${doc.id}');
          final tariff = Tariff.fromFirestore(doc);
          tariffs.add(tariff);
          _logger.v('✅ Успешно создан тариф: ${tariff.title}');
        } catch (e, stackTrace) {
          _logger.e('❌ Ошибка при создании тарифа из документа ${doc.id}',
              error: e,
              stackTrace: stackTrace);
        }
      }

      _logger.i('🎉 Загружено ${tariffs.length} тарифов');
      return tariffs;
    } catch (e, stackTrace) {
      _logger.e('💥 Критическая ошибка при загрузке тарифов',
          error: e,
          stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<UserProfile> fetchUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserProfile.fromFirestore(doc);
  }


  static Future<Map<String, dynamic>> createPayment(Tariff tariff) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final returnUrl = 'gladiatorapp://payment/return?user=$userId&success={success}';

    final response = await http.post(
      Uri.parse('$BASE_URL/api/payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'value': tariff.price,
        'orderID': DateTime.now().millisecondsSinceEpoch.toString(),
        'userUID': userId,
        'tariffId': tariff.id,
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

  static Future<Subscription?> fetchSubscription() async {
    try {
      final profile = await SubscriptionService.fetchUserProfile();
      final subscriptionDoc = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(profile.activeSubscriptionId)
          .get();

      if (!subscriptionDoc.exists) {
        return null;
      }

      // Конвертируем в модель Subscription
      final subscription = Subscription.fromFirestore(subscriptionDoc);

      // Проверяем, активна ли подписка
      return subscription;
    } catch (e) {
      debugPrint('Ошибка получения подписки: $e');
      return null;
    }
  }


  static Future<Map<String, dynamic>> generateQrCode(String userId) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/subscription/generate-qr'),
      body: jsonEncode({'userId': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate QR: ${response.body}');
    }
  }

  static Future<bool> validateQrCode(String qrCode, String adminId) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/subscription/validate-qr'),
      body: jsonEncode({'qrCode': qrCode, 'adminId': adminId}),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200;
  }

}
