// lib/services/widget_service.dart

import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/task_model.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.mokges.app';
  static const String _widgetName = 'MokgesWidget';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> updateWidget(List<TaskModel> tasks) async {
    // Bugungi bajarilmagan va eng yaqin vaqtli 3 ta ish
    final now = DateTime.now();
    final pendingTasks = tasks
        .where((t) => !t.isCompleted && t.scheduledTime != null)
        .where((t) => t.scheduledTime!.isAfter(now))
        .toList()
      ..sort((a, b) =>
          a.scheduledTime!.compareTo(b.scheduledTime!));

    final topTasks = pendingTasks.take(3).toList();

    // Widget data ni save qilish
    await HomeWidget.saveWidgetData<String>(
      'tasks_count',
      topTasks.length.toString(),
    );

    for (int i = 0; i < 3; i++) {
      if (i < topTasks.length) {
        final task = topTasks[i];
        final timeStr = task.scheduledTime != null
            ? '${task.scheduledTime!.hour.toString().padLeft(2, '0')}:${task.scheduledTime!.minute.toString().padLeft(2, '0')}'
            : '';
        await HomeWidget.saveWidgetData<String>(
            'task_${i}_title', task.title);
        await HomeWidget.saveWidgetData<String>(
            'task_${i}_time', timeStr);
      } else {
        await HomeWidget.saveWidgetData<String>('task_${i}_title', '');
        await HomeWidget.saveWidgetData<String>('task_${i}_time', '');
      }
    }

    await HomeWidget.updateWidget(
      name: _widgetName,
      androidName: _widgetName,
      iOSName: _widgetName,
    );
  }
}
