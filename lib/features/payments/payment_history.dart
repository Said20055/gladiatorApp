import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История платежей'),
        centerTitle: true,
      ),
      body: _buildPaymentHistoryContent(),
    );
  }

  Widget _buildPaymentHistoryContent() {
    if (_currentUserId == null) {
      return const Center(child: Text('Требуется авторизация'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('payments')
          .where('userUID', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Обработка ошибки индекса
        if (snapshot.hasError &&
            (snapshot.error as FirebaseException).code == 'failed-precondition') {
          return _buildIndexRequiredWidget();
        }

        // Остальные ошибки
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        // Загрузка
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Нет данных
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Нет данных о платежах'));
        }

        // Отображение списка платежей
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final payment = snapshot.data!.docs[index];
            final data = payment.data() as Map<String, dynamic>;
            return _buildPaymentCard(data);
          },
        );
      },
    );
  }

  Widget _buildIndexRequiredWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber, size: 50, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Требуется настройка индекса',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Для работы этой функции администратору нужно создать специальный индекс в базе данных',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Повторить попытку'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Платеж #${_formatPaymentId(payment['paymentID'])}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(payment['status']),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(payment['status']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Сумма', '${payment['value']} ₽'),
            _buildInfoRow('Дата', _formatDate(payment['createdAt'])),
            if (payment['captured_at'] != null)
              _buildInfoRow('Подтвержден', _formatDate(payment['captured_at'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatPaymentId(String? id) {
    return id?.substring(0, 8) ?? 'N/A';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final timestamp = date as Timestamp;
    return _dateFormat.format(timestamp.toDate());
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded': return 'Успешно';
      case 'pending': return 'В обработке';
      case 'canceled': return 'Отменен';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded': return Colors.green;
      case 'pending': return Colors.orange;
      case 'canceled': return Colors.red;
      default: return Colors.grey;
    }
  }


}