import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gladiatorapp/core/services/subscription_service.dart';
import 'package:provider/provider.dart';

import '../../core/provider.dart';
import 'news_detail_screen.dart';
import 'workouts.dart';
 // Импортируем ThemeProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingSubscription = true;
  bool _hasActiveSubscription = false;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
      final subscriptions = await SubscriptionService.fetchSubscription();
      _isLoadingSubscription = false;
      _hasActiveSubscription = subscriptions?.isValid ?? false;
  }

  Future<void> _onNavBarTap(int index) async {
    switch (index) {
      case 0:
        break;
      case 1:
        if (_isLoadingSubscription) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              content: Row(
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Проверяем статус подписки...',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          await _fetchSubscriptionStatus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutsScreen(hasActiveSubscription: _hasActiveSubscription),
            ),
          );
        }
        break;
      case 2:
        Navigator.pushNamed(context, '/progress');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cardWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Главная',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('news')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Нет новостей',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            final todayNews = <QueryDocumentSnapshot>[];
            final otherNews = <QueryDocumentSnapshot>[];

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final createdDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

              if (createdDay == today) {
                todayNews.add(doc);
              } else {
                otherNews.add(doc);
              }
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 16),
                if (todayNews.isNotEmpty) ...[
                  Text(
                    "Новости сегодняшнего дня",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: todayNews.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final data = todayNews[index].data() as Map<String, dynamic>;
                        return _highlightCard(
                          context: context,
                          width: cardWidth,
                          title: data['title'] ?? '',
                          subtitle: data['description'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          fullDescription: data['fullDescription'] ?? '',
                          category: data['category'] ?? '',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  "Последние новости",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                ...otherNews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _newsItem(
                    context: context,
                    category: data['category'] ?? '',
                    title: data['title'] ?? '',
                    subtitle: data['description'] ?? '',
                    fullDescription: data['fullDescription'] ?? '',
                    imageUrl: data['imageUrl'] ?? '',
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).bottomAppBarTheme.color,
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Colors.redAccent[700], // Ярко-красный цвет для выделения
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600, // Более жирный для активного элемента
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).bottomAppBarTheme.color,
          elevation: 8,
          selectedIconTheme: IconThemeData(
            size: 28, // Немного увеличиваем активную иконку
          ),
          unselectedIconTheme: IconThemeData(
            size: 24,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Тренировки',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Прогресс',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
          onTap: _onNavBarTap,
        ),
      ),
    );
  }

  Widget _highlightCard({
    required BuildContext context,
    required double width,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String fullDescription,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(
              title: title,
              description: subtitle,
              fullDescription: fullDescription,
              imageUrl: imageUrl,
              category: category,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsItem({
    required BuildContext context,
    required String category,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String fullDescription,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(
              title: title,
              description: subtitle,
              fullDescription: fullDescription,
              imageUrl: imageUrl,
              category: category,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).disabledColor,
                  child: Icon(Icons.broken_image, color: Theme.of(context).iconTheme.color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}