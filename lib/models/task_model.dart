// lib/models/task_model.dart

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledTime;
  final bool isCompleted;
  final int priority; // 1=Low, 2=Medium, 3=High
  final DateTime createdAt;
  final bool isSnooze;
  final DateTime? snoozeUntil;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.scheduledTime,
    this.isCompleted = false,
    this.priority = 2,
    required this.createdAt,
    this.isSnooze = false,
    this.snoozeUntil,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isCompleted,
    int? priority,
    DateTime? createdAt,
    bool? isSnooze,
    DateTime? snoozeUntil,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isSnooze: isSnooze ?? this.isSnooze,
      snoozeUntil: snoozeUntil ?? this.snoozeUntil,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'isSnooze': isSnooze ? 1 : 0,
      'snoozeUntil': snoozeUntil?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'] as String)
          : null,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: map['priority'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSnooze: (map['isSnooze'] as int) == 1,
      snoozeUntil: map['snoozeUntil'] != null
          ? DateTime.parse(map['snoozeUntil'] as String)
          : null,
    );
  }
}
