import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../data/models/admin_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
    ),
  );

  Future<bool> checkAdminStatus() async {
    try {
      _logger.i('Проверка статуса администратора начата');
      final user = _auth.currentUser;

      if (user == null) {
        _logger.w('Пользователь не аутентифицирован');
        return false;
      }

      _logger.d('ID пользователя: ${user.uid}, email: ${user.email}');

      // Проверка кастомных claims
      final idToken = await user.getIdTokenResult(true);
      _logger.d('Токен пользователя: ${idToken.claims}');

      if (idToken.claims?['admin'] == true) {
        _logger.i('Админ доступ подтвержден через claims');
        return true;
      }

      // Проверка через Firestore
      _logger.d('Проверка документа администратора в Firestore');
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (!adminDoc.exists) {
        _logger.w('Документ администратора не найден для пользователя ${user.uid}');
      } else {
        _logger.i('Админ доступ подтвержден через Firestore');
      }

      return adminDoc.exists;
    } catch (e, stack) {
      _logger.e('Ошибка проверки статуса администратора',
          error: e,
          stackTrace: stack);
      return false;
    }
  }

  Future<AdminUser?> getAdminUser() async {
    try {
      _logger.i('Получение данных администратора');
      final user = _auth.currentUser;

      if (user == null) {
        _logger.w('Пользователь не аутентифицирован');
        return null;
      }

      _logger.d('Запрос документа администратора для ${user.uid}');
      final adminDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (!adminDoc.exists) {
        _logger.w('Документ администратора не найден');
        return null;
      }

      final adminUser = AdminUser.fromFirestore(adminDoc);
      _logger.i('Данные администратора получены: ${adminUser.email}, роль: ${adminUser.role}');

      return adminUser;
    } catch (e, stack) {
      _logger.e('Ошибка получения данных администратора',
          error: e,
          stackTrace: stack);
      return null;
    }
  }
}