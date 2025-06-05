import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'workouts.dart';

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Если по каким-то причинам нет залогиненного пользователя,
      // считаем, что подписки нет и выключаем загрузчик.
      setState(() {
        _hasActiveSubscription = false;
        _isLoadingSubscription = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        // Предположим, что в Firestore вы храните какой-то флаг,
        // например: 'hasPremium': true/false
        // или проверяете по activeTariffId != null
        if ((data['hasPremium'] as bool?) == true || (data['activeTariffId'] as String?) != null) {
          _hasActiveSubscription = true;
        } else {
          _hasActiveSubscription = false;
        }
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке статуса подписки: $e');
      _hasActiveSubscription = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSubscription = false;
        });
      }
    }
  }

   Future<void>  _onNavBarTap(int index) async {
    switch (index) {
      case 0:
      // Главная — ничего не делаем, мы уже тут
        break;
      case 1:
      // Тренировки
        if (_isLoadingSubscription) {
          // Пока статус подписки не загружен — показываем диалог
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Expanded(child: Text('Проверяем статус подписки...')),
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
      // Прогресс
        Navigator.pushNamed(context, '/progress');
        break;
      case 3:
      // Профиль
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Главная'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () { Navigator.pushNamed(context, '/settings'); },
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
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Нет новостей'));
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
                  const Text(
                    "Новости сегодняшнего дня",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          subtitle: data['subtitle'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  "Последние новости",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...otherNews.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _newsItem(
                    category: data['category'] ?? '',
                    title: data['title'] ?? '',
                    subtitle: data['subtitle'] ?? '',
                    imageUrl: data['imageUrl'] ?? '',
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Тренировки'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _highlightCard({
    required BuildContext context,
    required double width,
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
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
    );
  }

  Widget _newsItem({
    required String category,
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
