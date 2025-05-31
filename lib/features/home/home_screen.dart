import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.7; // Выносим расчет ширины карточки

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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          const Text(
            "Новости сегодняшнего дня",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(width: 4),
                _highlightCard(
                    context: context,
                    width: cardWidth,
                    title: 'Morning Yoga',
                    subtitle: 'Start your day with a calming yoga session.',
                    imageUrl: 'https://via.placeholder.com/150'
                ),
                _highlightCard(
                    context: context,
                    width: cardWidth,
                    title: 'Nutrition Tips',
                    subtitle: 'Fuel your body with smart recipes.',
                    imageUrl: 'https://via.placeholder.com/150'
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Последние новости",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _newsItem(
              category: 'Fitness',
              title: '5 Ways to Stay Motivated',
              subtitle: 'Tips to keep your fitness journey on track.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Nutrition',
              title: 'Healthy Eating Habits',
              subtitle: 'Learn how to maintain a balanced diet.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Workouts',
              title: 'Quick Home Workouts',
              subtitle: 'Effective exercises you can do at home.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Workouts',
              title: 'Quick Home Workouts',
              subtitle: 'Effective exercises you can do at home.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Workouts',
              title: 'Quick Home Workouts',
              subtitle: 'Effective exercises you can do at home.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Workouts',
              title: 'Quick Home Workouts',
              subtitle: 'Effective exercises you can do at home.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          _newsItem(
              category: 'Workouts',
              title: 'Quick Home Workouts',
              subtitle: 'Effective exercises you can do at home.',
              imageUrl: 'https://via.placeholder.com/100'
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 4) { // Предположим, что профиль третий в списке
            Navigator.pushNamed(context, '/profile');
          }
        },
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
      margin: const EdgeInsets.only(right: 12),
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