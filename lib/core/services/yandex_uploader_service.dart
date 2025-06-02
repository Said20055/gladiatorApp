import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:gladiatorapp/configs/yandex_config.dart';

class YandexUploaderService {
  static Future<String?> uploadFile(File file) async {
    try {
      // Проверка размера файла (макс. 5MB)
      if (await file.length() > 5 * 1024 * 1024) {
        throw Exception('Файл слишком большой (макс. 5MB)');
      }

      final accessKey = YandexConfig.accessKey;
      final secretKey = YandexConfig.secretKey;
      final bucket = YandexConfig.bucketName;
      final region = YandexConfig.region;

      final now = DateTime.now().toUtc();
      final date = DateFormat('yyyyMMdd').format(now);
      final amzDate = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(now);
      final service = 's3';
      final host = '$bucket.storage.yandexcloud.net';

      // Генерируем уникальное имя файла
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final endpoint = Uri.https(host, '/$filename');

      final credentialScope = '$date/$region/$service/aws4_request';
      final payload = await file.readAsBytes();
      final payloadHash = sha256.convert(payload).toString();

      final canonicalHeaders = [
        'host:$host',
        'x-amz-content-sha256:$payloadHash',
        'x-amz-date:$amzDate'
      ].join('\n');

      final canonicalRequest = [
        'PUT',
        '/$filename',
        '',
        canonicalHeaders,
        '',
        'host;x-amz-content-sha256;x-amz-date',
        payloadHash,
      ].join('\n');

      final stringToSign = [
        'AWS4-HMAC-SHA256',
        amzDate,
        credentialScope,
        sha256.convert(utf8.encode(canonicalRequest)).toString(),
      ].join('\n');

      List<int> _sign(List<int> key, String message) =>
          Hmac(sha256, key).convert(utf8.encode(message)).bytes;

      final dateKey = _sign(utf8.encode('AWS4$secretKey'), date);
      final regionKey = _sign(dateKey, region);
      final serviceKey = _sign(regionKey, service);
      final signingKey = _sign(serviceKey, 'aws4_request');

      final signature = Hmac(sha256, signingKey)
          .convert(utf8.encode(stringToSign)).toString();

      final authorization = [
        'AWS4-HMAC-SHA256 Credential=$accessKey/$credentialScope',
        'SignedHeaders=host;x-amz-content-sha256;x-amz-date',
        'Signature=$signature',
      ].join(', ');

      final response = await http.put(
        endpoint,
        headers: {
          'Host': host,
          'x-amz-content-sha256': payloadHash,
          'x-amz-date': amzDate,
          'Authorization': authorization,
          'Content-Type': 'image/jpeg', // Указываем тип контента
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        return 'https://$host/$filename';
      } else {
        throw Exception('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка в YandexUploaderService: $e');
      return null;
    }
  }
}