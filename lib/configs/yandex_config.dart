import 'package:flutter_dotenv/flutter_dotenv.dart';

class YandexConfig {
  static String get bucketName => _getEnv('YANDEX_BUCKET');
  static String get region => 'ru-central1';
  static String get accessKey => _getEnv('YANDEX_ACCESS_KEY');
  static String get secretKey => _getEnv('YANDEX_SECRET_KEY');

  static String _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('Не найдена переменная $key в .env файле');
    }
    return value;
  }
}