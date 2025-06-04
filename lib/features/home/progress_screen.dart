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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Прогресс',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ───────────── Форма ввода данных ─────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Добавить запись о весе',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Вес (кг)',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Дата',
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, color: Colors.red),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _addWeightRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Добавить',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'График изменения веса',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          backgroundColor: Colors.white,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withOpacity(0.2),
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
                                  final date =
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      DateFormat('MM.dd').format(date),
                                      style: const TextStyle(
                                        color: Colors.black54,
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
                                    style: const TextStyle(
                                      color: Colors.black54,
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
                            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
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
                              color: Colors.red,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true), // Здесь убраны dotColor и dotSize
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ───────────── История записей ─────────────
            if (_weightRecords.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'История записей',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        '${record.weight.toStringAsFixed(1)} кг',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd').format(record.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRecord(index),
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
