// lib/models/habit_model.dart

class HabitModel {
  final String id;
  final String title;
  final String? description;
  final String emoji;
  final TimeOfDay? reminderTime;
  final List<int> repeatDays; // 1=Mon ... 7=Sun, empty=everyday
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final String color; // hex color string

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    this.emoji = '⭐',
    this.reminderTime,
    this.repeatDays = const [],
    this.completedDates = const [],
    required this.createdAt,
    this.color = '#6C63FF',
  });

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final lastCompleted = DateTime(
        sorted.first.year, sorted.first.month, sorted.first.day);

    if (lastCompleted != todayNorm) {
      final yesterday = todayNorm.subtract(const Duration(days: 1));
      if (lastCompleted != yesterday) return 0;
    }

    for (int i = 0; i < 365; i++) {
      final day = todayNorm.subtract(Duration(days: i));
      final isCompleted = completedDates.any((d) =>
          d.year == day.year && d.month == day.month && d.day == day.day);
      if (isCompleted) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get maxStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = List<DateTime>.from(completedDates)
      ..sort((a, b) => a.compareTo(b));

    int maxS = 0;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime(
          sorted[i - 1].year, sorted[i - 1].month, sorted[i - 1].day);
      final curr =
          DateTime(sorted[i].year, sorted[i].month, sorted[i].day);
      final diff = curr.difference(prev).inDays;
      if (diff == 1) {
        current++;
        if (current > maxS) maxS = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    if (maxS == 0 && sorted.isNotEmpty) maxS = 1;
    return maxS;
  }

  // 1 kundan boshlanadigan progress (21 kunlik emas, faqat streak va kun soni)
  int get daysSinceStart {
    final now = DateTime.now();
    return now.difference(createdAt).inDays + 1;
  }

  // Necha kun bajarilgan (jami)
  int get totalCompletedDays => completedDates.length;

  // Streak progress (% sifatida, 21 kunga nisbatan)
  double get streakProgress {
    return (currentStreak / 21).clamp(0.0, 1.0);
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any((d) =>
        d.year == today.year &&
        d.month == today.month &&
        d.day == today.day);
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    TimeOfDay? reminderTime,
    List<int>? repeatDays,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    String? color,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      reminderTime: reminderTime ?? this.reminderTime,
      repeatDays: repeatDays ?? this.repeatDays,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'repeatDays': repeatDays.join(','),
      'completedDates':
          completedDates.map((d) => d.toIso8601String()).join(','),
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminderTime;
    if (map['reminderHour'] != null && map['reminderMinute'] != null) {
      reminderTime = TimeOfDay(
          hour: map['reminderHour'] as int,
          minute: map['reminderMinute'] as int);
    }

    List<int> repeatDays = [];
    if (map['repeatDays'] != null && (map['repeatDays'] as String).isNotEmpty) {
      repeatDays = (map['repeatDays'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }

    List<DateTime> completedDates = [];
    if (map['completedDates'] != null &&
        (map['completedDates'] as String).isNotEmpty) {
      completedDates = (map['completedDates'] as String)
          .split(',')
          .map((e) => DateTime.parse(e))
          .toList();
    }

    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      emoji: map['emoji'] as String? ?? '⭐',
      reminderTime: reminderTime,
      repeatDays: repeatDays,
      completedDates: completedDates,
      createdAt: DateTime.parse(map['createdAt'] as String),
      color: map['color'] as String? ?? '#6C63FF',
    );
  }
}

// Flutter TimeOfDay shunday import qilinadi:
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
