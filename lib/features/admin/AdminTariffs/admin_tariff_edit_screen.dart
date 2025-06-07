import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/tariff.dart';

class AdminTariffEditScreen extends StatefulWidget {
  final Tariff? tariff;

  const AdminTariffEditScreen({Key? key, this.tariff}) : super(key: key);

  @override
  State<AdminTariffEditScreen> createState() => _AdminTariffEditScreenState();
}

class _AdminTariffEditScreenState extends State<AdminTariffEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _redAccent = const Color(0xFFE53935);
  final _successColor = const Color(0xFF4CAF50);

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _sessionCountController;
  late TextEditingController _featuresController;
  bool _isBest = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tariff = widget.tariff;
    _titleController = TextEditingController(text: tariff?.title ?? '');
    _priceController = TextEditingController(text: tariff?.price.toString() ?? '');
    _durationController = TextEditingController(text: tariff?.duration ?? '1 месяц');
    _sessionCountController = TextEditingController(text: tariff?.sessionCount.toString() ?? '0');
    _featuresController = TextEditingController(text: tariff?.features.join('\n') ?? '');
    _isBest = tariff?.isBest ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _sessionCountController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _saveTariff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final title = _titleController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final duration = _durationController.text.trim();
    final sessionCount = int.tryParse(_sessionCountController.text.trim()) ?? 0;
    final features = _featuresController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final tariffData = {
      'title': title,
      'price': price,
      'duration': duration,
      'sessionCount': sessionCount,
      'features': features,
      'isBest': _isBest,
    };

    try {
      final collection = FirebaseFirestore.instance.collection('tariffs');
      if (widget.tariff == null) {
        await collection.add(tariffData);
      } else {
        await collection.doc(widget.tariff!.id).update(tariffData);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при сохранении тарифа: $e'),
          backgroundColor: _redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteTariff() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Удалить тариф',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          'Вы уверены, что хотите удалить этот тариф?',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Удалить',
              style: TextStyle(color: _redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('tariffs').doc(widget.tariff!.id).delete();
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении тарифа: $e'),
            backgroundColor: _redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.tariff != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          isEditing ? 'Редактировать тариф' : 'Добавить тариф',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        iconTheme: IconThemeData(color: _redAccent),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete, color: _redAccent),
              onPressed: _deleteTariff,
              tooltip: 'Удалить тариф',
            ),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Название',
                validator: (value) => value == null || value.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Цена (₽)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите цену';
                  if (int.tryParse(value) == null) return 'Введите корректное число';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _durationController,
                label: 'Длительность',
                hint: 'например, 1 месяц',
                validator: (value) => value == null || value.isEmpty ? 'Введите длительность' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _sessionCountController,
                label: 'Количество тренировок',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите количество тренировок';
                  if (int.tryParse(value) == null) return 'Введите корректное число';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _featuresController,
                label: 'Особенности',
                hint: 'Каждая особенность с новой строки',
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Лучший тариф',
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Показывать с выделением',
                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                  ),
                  value: _isBest,
                  activeColor: _redAccent,
                  onChanged: (val) => setState(() => _isBest = val),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTariff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isEditing ? 'СОХРАНИТЬ ИЗМЕНЕНИЯ' : 'ДОБАВИТЬ ТАРИФ',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}