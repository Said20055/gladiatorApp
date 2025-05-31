// lib/screens/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/tariff.dart'; // <-- путь к вашей модели

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Tariff? _selectedTariff;

  /// Функция для загрузки всех тарифов из коллекции "tariffs"
  Future<List<Tariff>> _fetchTariffs() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('tariffs').get();
    return querySnapshot.docs.map((doc) => Tariff.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar с иконкой закрытия и заголовком
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      // Body: FutureBuilder, который ждет список тарифов
      body: FutureBuilder<List<Tariff>>(
        future: _fetchTariffs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Пока идет загрузка — индикатор
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Если ошибка при загрузке — ошибка
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
                        // Попробовать загрузить еще раз
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
            // Если список тарифов пуст
            return const Center(child: Text('Тарифы не найдены'));
          }

          // Когда тарифы загружены — рисуем экран
          return _buildSubscriptionContent(tariffs);
        },
      ),
    );
  }

  Widget _buildSubscriptionContent(List<Tariff> tariffs) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Заголовок и подзаголовок
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: const [
              Text(
                'Unlock premium features',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Get доступ ко всем тренировкам, персональным планам и другим фишкам.',
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
        // Список тарифов в скролле
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tariffs.length + 1, // +1 для отступа снизу
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
                // Просто пустой SizedBox для отступа снизу
                return const SizedBox(height: 48);
              }
            },
          ),
        ),
        // Кнопка Pay Now
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
                'Pay Now',
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

  /// Строим карточку для одного тарифа
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
              // Название тарифа и галочка, если выбран
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
              // Цена
              Text(
                '${tariff.price} ₽',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Список фич
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
              // Кнопка Select / Selected
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
                    isSelected ? 'Selected' : 'Select',
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

        // Если тариф отмечен как isBest, показываем бейдж «Best Value»
        if (tariff.isBest)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Text(
                'Best Value',
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

  /// Обработчик нажатия «Pay Now»
  void _onPayNowPressed() {
    if (_selectedTariff == null) return;

    final String name = _selectedTariff!.title;
    final int price = _selectedTariff!.price;

    // Здесь можно запустить интеграцию с YooKassa,
    // передав выбранный тариф (_selectedTariff).

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text(
          'Вы выбрали тариф:\n'
              '» $name — $price ₽\n\n'
              'Перейти к оплате?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: здесь запускать SDK YooKassa или WebView оплаты
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }
}
