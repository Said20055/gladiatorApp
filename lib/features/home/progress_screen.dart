import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final List<WeightRecord> _weightRecords = [];
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final Color _primaryColor = const Color(0xFFE53935); // Красный акцент
  final Color _successColor = const Color(0xFF4CAF50); // Зеленый для позитивных изменений

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Тестовые данные для демонстрации
    _weightRecords.addAll([
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 6)), weight: 75),
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 5)), weight: 74.5),
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 4)), weight: 74),
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 3)), weight: 73.8),
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 2)), weight: 73.5),
      WeightRecord(date: DateTime.now().subtract(const Duration(days: 1)), weight: 73.2),
      WeightRecord(date: DateTime.now(), weight: 73),
    ]);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor, // Красный для выбора даты
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  void _addWeightRecord() {
    if (_weightController.text.isEmpty) return;
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;

    setState(() {
      _weightRecords.add(WeightRecord(date: _selectedDate, weight: weight));
      _weightRecords.sort((a, b) => a.date.compareTo(b.date));
      _weightController.clear();
    });
  }

  void _deleteRecord(int index) {
    setState(() {
      _weightRecords.removeAt(index);
    });
  }

  List<FlSpot> _getSpots() {
    return _weightRecords.map((record) {
      return FlSpot(
        record.date.millisecondsSinceEpoch.toDouble(),
        record.weight,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Прогресс',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ───────────── Форма ввода данных ─────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Добавить запись о весе',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Вес (кг)',
                        labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Дата',
                        labelStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                        suffixIcon: Icon(Icons.calendar_today, color: _primaryColor),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _addWeightRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Добавить запись',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ───────────── График прогресса ─────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'График изменения веса',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: LineChart(
                          LineChartData(
                            backgroundColor: theme.cardColor,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: theme.dividerColor.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                              getDrawingVerticalLine: (value) => FlLine(
                                color: theme.dividerColor.withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 86400000, // 1 день
                                  getTitlesWidget: (value, meta) {
                                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        DateFormat('MM.dd').format(date),
                                        style: TextStyle(
                                          color: theme.textTheme.bodySmall?.color,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: _calculateInterval(),
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            minX: _weightRecords.isNotEmpty
                                ? _weightRecords.first.date.millisecondsSinceEpoch.toDouble()
                                : 0,
                            maxX: _weightRecords.isNotEmpty
                                ? _weightRecords.last.date.millisecondsSinceEpoch.toDouble()
                                : 1,
                            minY: _weightRecords.isNotEmpty
                                ? _weightRecords
                                .map((r) => r.weight)
                                .reduce((a, b) => a < b ? a : b) -
                                2
                                : 0,
                            maxY: _weightRecords.isNotEmpty
                                ? _weightRecords
                                .map((r) => r.weight)
                                .reduce((a, b) => a > b ? a : b) +
                                2
                                : 1,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getSpots(),
                                isCurved: true,
                                color: _primaryColor,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 5,
                                      color: _primaryColor,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: _primaryColor.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Начальный вес',
                          value: _weightRecords.isNotEmpty
                              ? '${_weightRecords.first.weight.toStringAsFixed(1)} кг'
                              : '-',
                        ),
                        _buildStatCard(
                          context,
                          title: 'Текущий вес',
                          value: _weightRecords.isNotEmpty
                              ? '${_weightRecords.last.weight.toStringAsFixed(1)} кг'
                              : '-',
                        ),
                        _buildStatCard(
                          context,
                          title: 'Изменение',
                          value: _weightRecords.length > 1
                              ? '${(_weightRecords.last.weight - _weightRecords.first.weight).toStringAsFixed(1)} кг'
                              : '-',
                          isPositive: _weightRecords.length > 1
                              ? _weightRecords.last.weight < _weightRecords.first.weight
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ───────────── История записей ─────────────
            if (_weightRecords.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'История записей',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weightRecords.length,
                itemBuilder: (context, index) {
                  final record = _weightRecords[index];
                  final isFirst = index == 0;
                  final isLast = index == _weightRecords.length - 1;
                  final double? change = index > 0
                      ? record.weight - _weightRecords[index - 1].weight
                      : null;

                  return Dismissible(
                    key: Key(record.date.toString() + record.weight.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Удалить запись?"),
                          content: Text(
                              "Вы уверены, что хотите удалить запись от ${DateFormat('dd.MM.yyyy').format(record.date)}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Отмена"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Удалить", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      setState(() {
                        _weightRecords.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Запись от ${DateFormat('dd.MM.yyyy').format(record.date)} удалена'),
                          action: SnackBarAction(
                            label: 'Отменить',
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                _weightRecords.insert(index, record);
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: theme.cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFirst || isLast
                                ? _primaryColor.withOpacity(0.2)
                                : theme.colorScheme.surfaceVariant,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isFirst || isLast
                                    ? _primaryColor
                                    : theme.textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          '${record.weight.toStringAsFixed(1)} кг',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('EEE, MMM d, y').format(record.date),
                          style: TextStyle(color: theme.textTheme.bodySmall?.color),
                        ),
                        trailing: change != null
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              change < 0 ? Icons.trending_down : Icons.trending_up,
                              color: change < 0 ? _successColor : Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              change.abs().toStringAsFixed(1),
                              style: TextStyle(
                                color: change < 0 ? _successColor : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    bool? isPositive,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isPositive != null
                    ? (isPositive ? _successColor : Colors.orange)
                    : theme.textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval() {
    if (_weightRecords.isEmpty) return 5;
    final min = _weightRecords.map((r) => r.weight).reduce((a, b) => a < b ? a : b);
    final max = _weightRecords.map((r) => r.weight).reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range <= 5) return 0.5;
    if (range <= 10) return 1;
    if (range <= 20) return 2;
    if (range <= 50) return 5;
    return 10;
  }
}

class WeightRecord {
  final DateTime date;
  final double weight;

  WeightRecord({required this.date, required this.weight});
}