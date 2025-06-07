import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/data/models/news_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/yandex_uploader_service.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _redAccent = const Color(0xFFE53935); // Основной красный цвет

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Управление новостями',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: _redAccent),
            onPressed: () => _showAddEditNewsDialog(context),
          ),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('news')
              .orderBy('createdAt', descending: true)
              .withConverter<Map<String, dynamic>>(
            fromFirestore: (snapshot, _) => snapshot.data()!,
            toFirestore: (data, _) => data,
          )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(
                'Ошибка: ${snapshot.error}',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(
                color: _redAccent,
              ));
            }

            final news = snapshot.data!.docs.map((doc) {
              return NewsItem.fromFirestore(doc);
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: news.length,
              itemBuilder: (context, index) {
                final item = news[index];
                return _buildNewsItem(context, item, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, NewsItem news, ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              news.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              news.description,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: _redAccent),
                  onPressed: () => _showAddEditNewsDialog(context, news: news),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: _redAccent),
                  onPressed: () => _deleteNews(context, news.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNews(BuildContext context, String newsId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Удалить новость?',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Text(
          'Вы уверены, что хотите удалить эту новость?',
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

    if (confirmed == true) {
      try {
        await _firestore.collection('news').doc(newsId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Новость успешно удалена'),
            backgroundColor: _redAccent,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении: $e'),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    }
  }

  Future<void> _showAddEditNewsDialog(BuildContext context, {NewsItem? news}) async {
    final titleController = TextEditingController(text: news?.title ?? '');
    final descriptionController = TextEditingController(text: news?.description ?? '');
    final fullDescriptionController = TextEditingController(text: news?.fullDescription ?? '');
    final categoryController = TextEditingController(text: news?.category ?? '');

    File? imageFile;
    String? imageUrl = news?.imageUrl;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  imageFile = File(pickedFile.path);
                  imageUrl = null;
                });
              }
            }

            Future<void> uploadImage() async {
              if (imageFile == null) return;
              setState(() => isUploading = true);
              try {
                final url = await YandexUploaderService.uploadFile(imageFile!);
                setState(() => imageUrl = url);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ошибка загрузки изображения: $e'),
                    backgroundColor: Colors.red[900],
                  ),
                );
              } finally {
                setState(() => isUploading = false);
              }
            }

            final theme = Theme.of(context);
            final isDarkMode = theme.brightness == Brightness.dark;

            return Dialog(
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        news == null ? 'Добавить новость' : 'Редактировать новость',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Превью изображения
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            imageFile!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.image, size: 20),
                              label: Text('Выбрать изображение'),
                              onPressed: pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                foregroundColor: theme.textTheme.bodyLarge?.color,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          if (imageFile != null && imageUrl == null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isUploading ? null : uploadImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isUploading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Text('Загрузить'),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: titleController,
                        label: 'Заголовок',
                        hint: 'Введите заголовок новости',
                        theme: theme,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: descriptionController,
                        label: 'Краткое описание',
                        hint: 'Введите краткое описание',
                        maxLines: 2,
                        theme: theme,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: fullDescriptionController,
                        label: 'Полное описание',
                        hint: 'Введите полный текст новости',
                        maxLines: 5,
                        theme: theme,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: categoryController,
                        label: 'Категория (необязательно)',
                        hint: 'Спорт, Соревнования...',
                        theme: theme,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.textTheme.bodyMedium?.color,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text('ОТМЕНА'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty ||
                                  descriptionController.text.isEmpty ||
                                  fullDescriptionController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Заполните обязательные поля'),
                                    backgroundColor: _redAccent,
                                  ),
                                );
                                return;
                              }

                              try {
                                final newsData = {
                                  'title': titleController.text,
                                  'description': descriptionController.text,
                                  'fullDescription': fullDescriptionController.text,
                                  'category': categoryController.text.isNotEmpty
                                      ? categoryController.text
                                      : null,
                                  'createdAt': news?.createdAt ?? DateTime.now(),
                                  if (imageUrl != null) 'imageUrl': imageUrl,
                                };

                                if (news == null) {
                                  await _firestore.collection('news').add(newsData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Новость успешно добавлена'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  await _firestore.collection('news').doc(news.id).update(newsData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Новость успешно обновлена'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ошибка: $e'),
                                    backgroundColor: Colors.red[900],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('СОХРАНИТЬ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    required ThemeData theme,
  }) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
        labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _redAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}