import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Модель тренировки
class Workout {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int duration; // в минутах
  final String difficulty;
  final bool isPremium;
  final String imageUrl; // URL изображения
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.difficulty,
    required this.isPremium,
    required this.imageUrl,
    required this.exercises,
  });
}

/// Модель одного упражнения
class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int rest; // в секундах

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
  });
}

/// Экран со списком тренировок
class WorkoutsScreen extends StatefulWidget {
  final bool hasActiveSubscription;

  const WorkoutsScreen({
    Key? key,
    required this.hasActiveSubscription,
  }) : super(key: key);

  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  late List<Workout> _workouts;

  @override
  void initState() {
    super.initState();
    _workouts = _generateWorkouts();
  }


  List<Workout> _generateWorkouts() {
    return [
      Workout(
        id: '3',
        title: 'Утренняя зарядка',
        description:
        'Легкая тренировка для пробуждения и заряда энергии на весь день',
        date: DateTime.now().subtract(const Duration(days: 1)),
        duration: 15,
        difficulty: 'Легкая',
        isPremium: false,
        imageUrl: 'https://cdn.culture.ru/images/23fc92b7-81f2-5552-b2c4-da12e40d4951',
        exercises: [
          Exercise(name: 'Наклоны головы', sets: 2, reps: 10, rest: 30),
          Exercise(name: 'Вращения плечами', sets: 2, reps: 10, rest: 30),
          Exercise(name: 'Наклоны вперед', sets: 3, reps: 8, rest: 45),
        ],
      ),
      Workout(
        id: '1',
        title: 'Кардио для выносливости',
        description: 'Улучшай сердечно-сосудистую систему и выносливость',
        date: DateTime.now().add(const Duration(days: 2)),
        duration: 35,
        difficulty: 'Средняя',
        isPremium: false,
        imageUrl: 'https://cdn.meteoprog.net/thumbnails/newsweather/cropr_1200x784/big_633257.jpg?1705230600',
        exercises: [
          Exercise(name: 'Бег на месте', sets: 3, reps: 2, rest: 60),
          Exercise(name: 'Прыжки с разведением рук и ног', sets: 3, reps: 25, rest: 45),
          Exercise(name: 'Выпады на месте', sets: 3, reps: 12, rest: 60),
        ],
      ),

      Workout(
        id: '6',
        title: 'Растяжка всего тела',
        description: 'Комплекс упражнений для гибкости и расслабления мышц',
        date: DateTime.now().subtract(const Duration(days: 2)),
        duration: 20,
        difficulty: 'Легкая',
        isPremium: false,
        imageUrl: 'https://avatars.mds.yandex.net/i?id=7809bb261e518f0f4413833e6cb54ca1_l-5024048-images-thumbs&n=13',
        exercises: [
          Exercise(name: 'Наклоны в стороны', sets: 2, reps: 12, rest: 30),
          Exercise(name: 'Повороты корпуса', sets: 2, reps: 10, rest: 30),
          Exercise(name: 'Растяжка ног сидя', sets: 3, reps: 15, rest: 45),
        ],
      ),
      Workout(
        id: '4',
        title: 'Силовая тренировка',
        description: 'Комплекс упражнений для развития силы всех групп мышц',
        date: DateTime.now(),
        duration: 45,
        difficulty: 'Средняя',
        isPremium: false,
        imageUrl: 'https://media.gqitalia.it/photos/61c32445ffa8ab477a2d447d/16:9/w_2560,c_limit/GettyImages-1131209175.jpg',
        exercises: [
          Exercise(name: 'Приседания', sets: 4, reps: 12, rest: 60),
          Exercise(name: 'Отжимания', sets: 4, reps: 10, rest: 60),
          Exercise(name: 'Подтягивания', sets: 3, reps: 8, rest: 90),
        ],
      ),
      Workout(
        id: '2',
        title: 'Премиум: Тренировка пресса',
        description: 'Интенсивная проработка мышц пресса для рельефа',
        date: DateTime.now().add(const Duration(days: 3)),
        duration: 25,
        difficulty: 'Высокая',
        isPremium: true,
        imageUrl: 'https://i.pinimg.com/originals/54/2d/7c/542d7c493f2da04d924d943bbabfd035.jpg',
        exercises: [
          Exercise(name: 'Скручивания', sets: 4, reps: 20, rest: 30),
          Exercise(name: 'Планка', sets: 3, reps: 1, rest: 60), // reps = 1 минута
          Exercise(name: 'Подъемы ног лежа', sets: 3, reps: 15, rest: 45),
        ],
      ),
      Workout(
        id: '5',
        title: 'Премиум: HIIT тренировка',
        description: 'Высокоинтенсивный интервальный тренинг для сжигания жира',
        date: DateTime.now().add(const Duration(days: 1)),
        duration: 30,
        difficulty: 'Высокая',
        isPremium: true,
        imageUrl: 'https://avatars.dzeninfra.ru/get-zen_doc/9196493/pub_643c17698bc7441bb9e08cf8_643c1c148bc7441bb9ea96b4/scale_1200',
        exercises: [
          Exercise(name: 'Берпи', sets: 5, reps: 15, rest: 45),
          Exercise(name: 'Прыжки на скакалке', sets: 5, reps: 30, rest: 45),
          Exercise(name: 'Скалолаз', sets: 5, reps: 20, rest: 30),
        ],
      ),

      Workout(
        id: '7',
        title: 'Премиум: Функциональная тренировка',
        description: 'Развивай баланс, силу и координацию',
        date: DateTime.now().add(const Duration(days: 4)),
        duration: 40,
        difficulty: 'Средняя',
        isPremium: true,
        imageUrl: 'https://avatars.mds.yandex.net/i?id=c17fd34f50d57ec077aa3cb15626c0c1_l-5877978-images-thumbs&n=13',
        exercises: [
          Exercise(name: 'Тяга гири к подбородку', sets: 3, reps: 12, rest: 45),
          Exercise(name: 'Присед + жим вверх', sets: 3, reps: 10, rest: 60),
          Exercise(name: 'Прыжки с поворотом', sets: 3, reps: 15, rest: 30),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Мои тренировки',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Если у пользователя нет подписки — показываем баннер
          if (!widget.hasActiveSubscription) _buildSubscriptionBanner(),
          // Список карточек тренировок
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return _buildWorkoutCard(workout);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Баннер-приглашение купить подписку
  Widget _buildSubscriptionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Премиум доступ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Чтобы получить полный доступ ко всем тренировкам, купите абонемент',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  /// Карточка одной тренировки в списке
  Widget _buildWorkoutCard(Workout workout) {
    final isLocked = workout.isPremium && !widget.hasActiveSubscription;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked
            ? () => _showSubscribeDialog()
            : () => _openWorkoutDetails(workout),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение тренировки
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: workout.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      height: 180,
                      child:
                      const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      height: 180,
                      child: const Icon(Icons.fitness_center,
                          size: 50, color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок и метка PREMIUM
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workout.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (workout.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PREMIUM',
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
                      // Дата и длительность
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _dateFormat.format(workout.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.timer,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.duration} мин',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Описание
                      Text(
                        workout.description,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Чипы: сложность и количество упражнений
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(workout.difficulty),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              workout.difficulty,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${workout.exercises.length} упражнений',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Если тренировка премиум и подписка не активна — накрываем затемнённым слоем
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Премиум контент',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Цвет фона для чипа сложности
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'легкая':
        return Colors.green;
      case 'средняя':
        return Colors.orange;
      case 'высокая':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Показать диалог с предложением оформить подписку
  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Премиум тренировка',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            'Эта тренировка доступна только для пользователей с активной подпиской'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Позже',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Купить подписку',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Открыть детали тренировки
  void _openWorkoutDetails(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(workout: workout),
      ),
    );
  }
}

/// Экран с деталями конкретной тренировки
class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailsScreen({Key? key, required this.workout})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          workout.title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение тренировки
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: workout.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  height: 220,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  height: 220,
                  child:
                  const Icon(Icons.fitness_center, size: 50, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Описание
            Text(
              workout.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Секция упражнений
            const Text(
              'Упражнения',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            ...workout.exercises.map((exercise) => _buildExerciseCard(exercise)).toList(),
          ],
        ),
      ),
    );
  }

  /// Карточка одного упражнения в деталях тренировки
  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExerciseStat('Подходы', '${exercise.sets}'),
                _buildExerciseStat('Повторения', '${exercise.reps}'),
                _buildExerciseStat('Отдых', '${exercise.rest} сек'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Виджет для одной статистики упражнения
  Widget _buildExerciseStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
