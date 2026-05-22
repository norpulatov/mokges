// lib/providers/app_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart' as h;
import '../models/journal_model.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ==================== THEME ====================
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ==================== TASKS ====================
class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final DatabaseService _db;
  final NotificationService _notifications;

  TasksNotifier(this._db, this._notifications)
      : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final tasks = await _db.getTodayTasks();
      state = AsyncValue.data(tasks);
      WidgetService.updateWidget(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(TaskModel task) async {
    await _db.insertTask(task);
    if (task.scheduledTime != null) {
      await _notifications.scheduleTaskNotification(
        id: task.id.hashCode,
        title: '📋 ${task.title}',
        body: 'Vazifani bajarishni unutmang!',
        scheduledTime: task.scheduledTime!,
      );
    }
    await _loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.updateTask(task);
    await _loadTasks();
  }

  Future<void> toggleComplete(TaskModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _db.updateTask(updated);
    await _loadTasks();
  }

  Future<void> deleteTask(TaskModel task) async {
    await _db.deleteTask(task.id);
    await _notifications.cancelNotification(task.id.hashCode);
    await _loadTasks();
  }

  Future<void> snoozeTask(TaskModel task, int minutes) async {
    final snoozeUntil = DateTime.now().add(Duration(minutes: minutes));
    final updated = task.copyWith(isSnooze: true, snoozeUntil: snoozeUntil);
    await _db.updateTask(updated);
    await _notifications.showSnoozeNotification(
      id: task.id.hashCode,
      title: task.title,
      snoozeMinutes: minutes,
    );
    await _loadTasks();
  }

  Future<void> refresh() => _loadTasks();
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>(
  (ref) => TasksNotifier(
    DatabaseService(),
    NotificationService(),
  ),
);

// ==================== HABITS ====================
class HabitsNotifier extends StateNotifier<AsyncValue<List<h.HabitModel>>> {
  final DatabaseService _db;
  final NotificationService _notifications;

  HabitsNotifier(this._db, this._notifications)
      : super(const AsyncValue.loading()) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      state = const AsyncValue.loading();
      final habits = await _db.getAllHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHabit(h.HabitModel habit) async {
    await _db.insertHabit(habit);
    if (habit.reminderTime != null) {
      await _notifications.scheduleHabitNotification(
        id: habit.id.hashCode,
        habitName: habit.title,
        hour: habit.reminderTime!.hour,
        minute: habit.reminderTime!.minute,
      );
    }
    await _loadHabits();
  }

  Future<void> toggleHabitToday(h.HabitModel habit) async {
    final today = DateTime.now();
    List<DateTime> newDates = List.from(habit.completedDates);

    final isToday = habit.isCompletedToday();
    if (isToday) {
      newDates.removeWhere((d) =>
          d.year == today.year &&
          d.month == today.month &&
          d.day == today.day);
    } else {
      newDates.add(today);
    }

    final updated = habit.copyWith(completedDates: newDates);
    await _db.updateHabit(updated);
    await _loadHabits();
  }

  Future<void> deleteHabit(h.HabitModel habit) async {
    await _db.deleteHabit(habit.id);
    await _notifications.cancelNotification(habit.id.hashCode);
    await _loadHabits();
  }

  Future<void> refresh() => _loadHabits();
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<h.HabitModel>>>(
  (ref) => HabitsNotifier(
    DatabaseService(),
    NotificationService(),
  ),
);

// ==================== JOURNAL ====================
class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final DatabaseService _db;

  JournalNotifier(this._db) : super(const AsyncValue.loading()) {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      state = const AsyncValue.loading();
      final entries = await _db.getAllJournalEntries();
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<JournalEntry?> getTodayEntry() async {
    return _db.getTodayJournalEntry();
  }

  Future<void> saveEntry(JournalEntry entry) async {
    // Bugun mavjud bo'lsa update, yo'q bo'lsa insert
    final existing = await _db.getTodayJournalEntry();
    if (existing != null) {
      final updated = entry.copyWith(id: existing.id);
      await _db.updateJournalEntry(updated);
    } else {
      await _db.insertJournalEntry(entry);
    }
    await _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _db.deleteJournalEntry(id);
    await _loadEntries();
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, AsyncValue<List<JournalEntry>>>(
  (ref) => JournalNotifier(DatabaseService()),
);

// ==================== AI ADVICE ====================
final aiAdviceProvider = FutureProvider<String>((ref) async {
  final habitsAsync = ref.watch(habitsProvider);
  final tasksAsync = ref.watch(tasksProvider);

  return habitsAsync.when(
    data: (habits) => tasksAsync.when(
      data: (tasks) {
        final completedToday = tasks.where((t) => t.isCompleted).length;
        final bestStreak =
            habits.isEmpty ? 0 : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

        return AiService().getAiAdvice(
          habitNames: habits.map((h) => h.title).toList(),
          completedTasks: completedToday,
          totalStreak: bestStreak,
        );
      },
      loading: () => Future.value(AiService().getRandomTip()),
      error: (_, __) => Future.value(AiService().getRandomTip()),
    ),
    loading: () => Future.value(AiService().getRandomTip()),
    error: (_, __) => Future.value(AiService().getRandomTip()),
  );
});

// ==================== STATS ====================
final weeklyStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return DatabaseService().getWeeklyStats();
});

// ==================== NAV ====================
final navIndexProvider = StateProvider<int>((ref) => 0);

// ==================== AI KEY ====================
final aiKeyProvider = StateProvider<String>((ref) => '');
