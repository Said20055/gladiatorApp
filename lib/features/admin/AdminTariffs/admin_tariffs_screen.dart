import 'package:flutter/material.dart';
import 'package:gladiatorapp/core/services/subscription_service.dart';
import 'package:gladiatorapp/data/models/tariff.dart';
import 'admin_tariff_edit_screen.dart';

class AdminTariffsScreen extends StatefulWidget {
  const AdminTariffsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTariffsScreen> createState() => _AdminTariffsScreenState();
}

class _AdminTariffsScreenState extends State<AdminTariffsScreen> {
  late Future<List<Tariff>> _tariffsFuture;
  final _redAccent = const Color(0xFFE53935);
  final _greenAccent = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _tariffsFuture = SubscriptionService.fetchTariffs();
  }

  void _refreshTariffs() {
    setState(() {
      _tariffsFuture = SubscriptionService.fetchTariffs();
    });
  }

  Widget _buildTariffCard(Tariff tariff, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminTariffEditScreen(tariff: tariff),
            ),
          ).then((value) {
            if (value == true) _refreshTariffs();
          });
        },
        child: Padding(
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
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  if (tariff.isBest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _greenAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ЛУЧШИЙ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${tariff.price} ₽',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tariff.duration,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${tariff.sessionCount} тренировок',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 12),
              ...tariff.features.take(2).map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 16, color: _redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              if (tariff.features.length > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ещё ${tariff.features.length - 2} особенностей',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Нажмите для редактирования',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: _redAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Управление тарифами',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: _redAccent),
        elevation: 1,
      ),
      body: FutureBuilder<List<Tariff>>(
        future: _tariffsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: _redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Ошибка загрузки тарифов: ${snapshot.error}',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
            );
          }

          final tariffs = snapshot.data ?? [];

          if (tariffs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_off,
                    size: 64,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Тарифы не найдены',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте первый тариф',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tariffs.length,
            itemBuilder: (context, index) {
              return _buildTariffCard(tariffs[index], context);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _redAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminTariffEditScreen(),
            ),
          ).then((value) {
            if (value == true) _refreshTariffs();
          });
        },
        tooltip: 'Добавить тариф',
      ),
    );
  }
}