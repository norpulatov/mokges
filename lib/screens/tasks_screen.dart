// lib/screens/tasks_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bugungi ishlar 📋',
                          style: theme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, d MMMM', 'uz').format(now),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(context),
                    );
                  }

                  final pending =
                      tasks.where((t) => !t.isCompleted).toList();
                  final completed =
                      tasks.where((t) => t.isCompleted).toList();

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stats row
                        _buildStatsRow(context, tasks),
                        const SizedBox(height: 20),

                        if (pending.isNotEmpty) ...[
                          Text('Bajarilmagan (${pending.length})',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          ...pending.asMap().entries.map((e) =>
                              _buildTaskCard(context, e.value, e.key)
                                  .animate()
                                  .slideX(
                                    begin: 0.3,
                                    delay: Duration(
                                        milliseconds: e.key * 80),
                                    curve: Curves.easeOut,
                                  )
                                  .fadeIn()),
                        ],

                        if (completed.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Bajarilgan ✅ (${completed.length})',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          ...completed.map((t) =>
                              _buildTaskCard(context, t, 0, isCompleted: true)),
                        ],
                        const SizedBox(height: 100),
                      ]),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(child: Text('Xatolik: $e')),
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              colors: const [
                AppTheme.primaryColor,
                AppTheme.secondary,
                AppTheme.accent,
                AppTheme.warning,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yangi ish'),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, List<TaskModel> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final percent = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF9B95FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completed / $total bajarildi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(percent * 100).toInt()}% tugatildi',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                percent == 1.0 ? '🎉' : '💪',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.9, 0.9),
          curve: Curves.easeOut,
          duration: 400.ms,
        );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task, int index,
      {bool isCompleted = false}) {
    final theme = Theme.of(context);
    final priorityColors = [
      Colors.grey,
      Colors.blue,
      AppTheme.warning,
      AppTheme.secondary,
    ];

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        ref.read(tasksProvider.notifier).deleteTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${task.title}' o'chirildi"),
            action: SnackBarAction(label: 'Bekor', onPressed: () {}),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? AppTheme.accent.withOpacity(0.3)
                : theme.colorScheme.surface,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: GestureDetector(
            onTap: () {
              if (!isCompleted) _confettiController.play();
              ref.read(tasksProvider.notifier).toggleComplete(task);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.accent
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.accent
                      : priorityColors[task.priority],
                  width: 2.5,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted
                  ? theme.textTheme.bodySmall?.color
                  : null,
            ),
          ),
          subtitle: task.scheduledTime != null
              ? Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(task.scheduledTime!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : null,
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_rounded),
                    SizedBox(width: 8),
                    Text('Tahrirlash')
                  ])),
              const PopupMenuItem(
                  value: 'snooze',
                  child: Row(children: [
                    Icon(Icons.snooze_rounded),
                    SizedBox(width: 8),
                    Text('15 min kechiktirish')
                  ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('O\'chirish',
                        style: TextStyle(color: Colors.red))
                  ])),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showAddTaskSheet(context, task: task);
                  break;
                case 'snooze':
                  ref.read(tasksProvider.notifier).snoozeTask(task, 15);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('⏰ 15 daqiqaga kechiktirildi')),
                  );
                  break;
                case 'delete':
                  ref.read(tasksProvider.notifier).deleteTask(task);
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📝', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Bugun hech qanday ish yo\'q!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Yangi ish qo\'shish uchun + tugmasini bosing',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, {TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        task: task,
        onSave: (newTask) {
          if (task != null) {
            ref.read(tasksProvider.notifier).updateTask(newTask);
          } else {
            ref.read(tasksProvider.notifier).addTask(newTask);
          }
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅 Xayrli tong!';
    if (hour < 17) return '☀️ Xayrli kun!';
    return '🌙 Xayrli kech!';
  }
}

// ==================== ADD TASK SHEET ====================
class AddTaskSheet extends StatefulWidget {
  final TaskModel? task;
  final Function(TaskModel) onSave;

  const AddTaskSheet({super.key, this.task, required this.onSave});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedTime;
  int _priority = 2;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _selectedTime = widget.task!.scheduledTime;
      _priority = widget.task!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.task == null ? '➕ Yangi ish' : '✏️ Tahrirlash',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Ish nomi *',
              prefixIcon: Icon(Icons.task_alt_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Tavsif (ixtiyoriy)',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Time picker
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime != null
                        ? DateFormat('HH:mm').format(_selectedTime!)
                        : 'Vaqt belgilash (ixtiyoriy)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  if (_selectedTime != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTime = null),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Priority
          Text('Muhimlik darajasi:',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              _priorityChip(1, '🟢 Past'),
              const SizedBox(width: 8),
              _priorityChip(2, '🟡 O\'rta'),
              const SizedBox(width: 8),
              _priorityChip(3, '🔴 Yuqori'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(
                  widget.task == null ? 'Saqlash' : 'Yangilash'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(int value, String label) {
    final isSelected = _priority == value;
    return GestureDetector(
      onTap: () => setState(() => _priority = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay.fromDateTime(_selectedTime!)
          : now,
    );
    if (picked != null) {
      final today = DateTime.now();
      setState(() {
        _selectedTime = DateTime(
            today.year, today.month, today.day, picked.hour, picked.minute);
      });
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ish nomini kiriting!')),
      );
      return;
    }

    final task = TaskModel(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      scheduledTime: _selectedTime,
      isCompleted: widget.task?.isCompleted ?? false,
      priority: _priority,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
    );

    widget.onSave(task);
    Navigator.pop(context);
  }
}
