import 'dart:async';

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
  final Color _primaryColor = const Color(0xFFE53935); // Красный акцент
  final Color _darkColor = const Color(0xFF121212); // Темный фон

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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? _darkColor : Colors.white,
      appBar: AppBar(
        title: Text(
          'Мои тренировки',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? _darkColor : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Column(
        children: [
          if (!widget.hasActiveSubscription) _buildSubscriptionBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return _buildWorkoutCard(workout, isDarkMode, theme); // Добавлен theme
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: _primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Премиум доступ',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Откройте все тренировки с подпиской',
                  style: TextStyle(
                    color: _primaryColor.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: _primaryColor),
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout, bool isDarkMode, ThemeData theme) { // Добавлен theme
    final isLocked = workout.isPremium && !widget.hasActiveSubscription;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLocked
            ? () => _showSubscribeDialog(theme) // Добавлен theme
            : () => _openWorkoutDetails(workout, theme), // Добавлен theme
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение с градиентом
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: CachedNetworkImage(
                        imageUrl: workout.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(color: _primaryColor),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          height: 180,
                          child: Icon(Icons.fitness_center, size: 50, color: _primaryColor),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.timer, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${workout.duration} мин',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(workout.difficulty),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  workout.difficulty,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.description,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _primaryColor),
                            ),
                            child: Text(
                              '${workout.exercises.length} упражнений',
                              style: TextStyle(
                                color: _primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (workout.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(20),
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
                    ],
                  ),
                ),
              ],
            ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          'Премиум контент',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  void _showSubscribeDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Премиум тренировка',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          'Эта тренировка доступна только для пользователей с активной подпиской',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Позже',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Купить подписку',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  void _openWorkoutDetails(Workout workout, ThemeData theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(workout: workout),
      ),
    );
  }
}

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailsScreen({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutDetailsScreenState createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  final Color _primaryColor = const Color(0xFFE53935);
  bool _isWorkoutStarted = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _secondsRemaining = 0;
  bool _isResting = false;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutStarted = true;
      _currentExerciseIndex = 0;
      _currentSet = 1;
      _startExercise();
    });
  }

  void _startExercise() {
    final exercise = widget.workout.exercises[_currentExerciseIndex];
    setState(() {
      _isResting = false;
      _secondsRemaining = exercise.reps * 2; // 2 секунды на повтор
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          if (_isResting) {
            _nextSetOrExercise();
          } else {
            _startRestPeriod();
          }
        }
      });
    });
  }

  void _startRestPeriod() {
    final exercise = widget.workout.exercises[_currentExerciseIndex];
    setState(() {
      _isResting = true;
      _secondsRemaining = exercise.rest;
    });
  }

  void _nextSetOrExercise() {
    final exercise = widget.workout.exercises[_currentExerciseIndex];

    if (_currentSet < exercise.sets) {
      setState(() {
        _currentSet++;
        _startExercise();
      });
    } else if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _startExercise();
      });
    } else {
      _timer.cancel();
      setState(() {
        _isWorkoutStarted = false;
      });
      _showWorkoutCompleteDialog();
    }
  }

  void _showWorkoutCompleteDialog() {
    final theme = Theme.of(context); // Получаем тему здесь

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Тренировка завершена!',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: Text(
          'Вы успешно завершили тренировку "${widget.workout.title}"',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.workout.title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: _isWorkoutStarted ? _buildWorkoutInProgress() : _buildWorkoutDetails(isDarkMode),
      floatingActionButton: !_isWorkoutStarted
          ? FloatingActionButton.extended(
        onPressed: _startWorkout,
        backgroundColor: _primaryColor,
        label: const Text('Начать тренировку', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.play_arrow, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildWorkoutInProgress() {
    final exercise = widget.workout.exercises[_currentExerciseIndex];
    final totalExercises = widget.workout.exercises.length;
    final progress = (_currentExerciseIndex / totalExercises).clamp(0.0, 1.0);

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: _primaryColor,
          minHeight: 4,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Упражнение ${_currentExerciseIndex + 1}/$totalExercises',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWorkoutStat('Подход', '$_currentSet/${exercise.sets}'),
                  _buildWorkoutStat(
                    _isResting ? 'Отдых' : 'Повторения',
                    _isResting
                        ? '${_secondsRemaining} сек'
                        : '${(_secondsRemaining / 2).ceil()}/${exercise.reps}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  _isResting
                      ? 'Отдых'
                      : '${(_secondsRemaining / 2).ceil()} ${_getRepWord((_secondsRemaining / 2).ceil())}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isResting)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      _nextSetOrExercise();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Пропустить отдых',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRepWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'повторение';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'повторения';
    }
    return 'повторений';
  }

  Widget _buildWorkoutStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutDetails(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.workout.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                height: 220,
                child: Center(child: CircularProgressIndicator(color: _primaryColor)),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                height: 220,
                child: Icon(Icons.fitness_center, size: 50, color: _primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.workout.description,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Упражнения',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.workout.exercises.map((exercise) => _buildExerciseCard(exercise, isDarkMode)).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
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
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildExerciseStat('Подходы', '${exercise.sets}', isDarkMode),
                _buildExerciseStat('Повторения', '${exercise.reps}', isDarkMode),
                _buildExerciseStat('Отдых', '${exercise.rest} сек', isDarkMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseStat(String title, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}