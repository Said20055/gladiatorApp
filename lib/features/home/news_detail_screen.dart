import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String fullDescription;
  final String? imageUrl;
  final String? category;

  final Color primaryColor = const Color(0xFFE53935); // Красный акцент
  final Color secondaryColor = const Color(0xFF424242); // Темно-серый

  const NewsDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.fullDescription,
    this.imageUrl,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Категория с красным акцентом
            if (category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text(
                  category!,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Заголовок
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Изображение с тенью и скруглением
            if (imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: theme.cardColor,
                      child: Icon(
                        Icons.broken_image,
                        color: theme.iconTheme.color,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Краткое описание
            Text(
              description,
              style: TextStyle(
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.9),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Разделитель с красным акцентом
            Container(
              height: 4,
              width: 80,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Полное описание
            Text(
              fullDescription,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 32),

            // Кнопка "Назад" с красным акцентом
            Center(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Вернуться к новостям',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}