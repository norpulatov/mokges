// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/habit_model.dart' as h;
import '../models/journal_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mokges.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        scheduledTime TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 2,
        createdAt TEXT NOT NULL,
        isSnooze INTEGER NOT NULL DEFAULT 0,
        snoozeUntil TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        emoji TEXT NOT NULL DEFAULT '⭐',
        reminderHour INTEGER,
        reminderMinute INTEGER,
        repeatDays TEXT NOT NULL DEFAULT '',
        completedDates TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL,
        color TEXT NOT NULL DEFAULT '#6C63FF'
      )
    ''');

    await db.execute('''
      CREATE TABLE journal (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL DEFAULT '😊',
        moodScore INTEGER NOT NULL DEFAULT 3,
        tags TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS journal (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          content TEXT NOT NULL,
          mood TEXT NOT NULL DEFAULT '😊',
          moodScore INTEGER NOT NULL DEFAULT 3,
          tags TEXT NOT NULL DEFAULT ''
        )
      ''');
    }
  }

  // ==================== TASKS ====================

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'tasks',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      orderBy: 'scheduledTime ASC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getWeeklyStats() async {
    final db = await database;
    final Map<String, int> stats = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await db.query(
        'tasks',
        where: 'createdAt >= ? AND createdAt < ? AND isCompleted = 1',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
      );

      final dayKey = '${day.day}/${day.month}';
      stats[dayKey] = result.length;
    }
    return stats;
  }

  // ==================== HABITS ====================

  Future<List<h.HabitModel>> getAllHabits() async {
    final db = await database;
    final maps = await db.query('habits', orderBy: 'createdAt ASC');
    return maps.map((m) => h.HabitModel.fromMap(m)).toList();
  }

  Future<void> insertHabit(h.HabitModel habit) async {
    final db = await database;
    await db.insert('habits', habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateHabit(h.HabitModel habit) async {
    final db = await database;
    await db.update('habits', habit.toMap(),
        where: 'id = ?', whereArgs: [habit.id]);
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== JOURNAL ====================

  Future<List<JournalEntry>> getAllJournalEntries() async {
    final db = await database;
    final maps = await db.query('journal', orderBy: 'date DESC');
    return maps.map((m) => JournalEntry.fromMap(m)).toList();
  }

  Future<JournalEntry?> getTodayJournalEntry() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final maps = await db.query(
      'journal',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  Future<void> insertJournalEntry(JournalEntry entry) async {
    final db = await database;
    await db.insert('journal', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    final db = await database;
    await db.update('journal', entry.toMap(),
        where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<void> deleteJournalEntry(String id) async {
    final db = await database;
    await db.delete('journal', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
