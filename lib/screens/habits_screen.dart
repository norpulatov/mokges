// lib/screens/habits_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart' as h;
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Odatlarim 🔄',
                        style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Har kun yangi qadam — odat qur!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSummaryRow(context, habits),
                    const SizedBox(height: 20),
                    ...habits.asMap().entries.map((e) =>
                        _buildHabitCard(context, ref, e.value, e.key)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yangi odat'),
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context, List<h.HabitModel> habits) {
    final completedToday =
        habits.where((h) => h.isCompletedToday()).length;
    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '✅',
            label: 'Bugun bajarildi',
            value: '$completedToday / ${habits.length}',
            color: AppTheme.accent,
          ).animate().slideY(begin: 0.3).fadeIn(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            emoji: '🔥',
            label: 'Eng uzun streak',
            value: '$bestStreak kun',
            color: AppTheme.secondary,
          ).animate().slideY(begin: 0.3, delay: 100.ms).fadeIn(),
        ),
      ],
    );
  }

  Widget _buildHabitCard(BuildContext context, WidgetRef ref,
      h.HabitModel habit, int index) {
    final theme = Theme.of(context);
    final color = AppColors.fromHex(habit.color);
    final isToday = habit.isCompletedToday();
    final daysSince = habit.daysSinceStart;
    final streak = habit.currentStreak;
    final progress = habit.streakProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isToday ? color.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday ? color.withOpacity(0.2) : Colors.black12,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(habit.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title,
                          style: theme.textTheme.titleLarge),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} kunlik streak',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Check button
                GestureDetector(
                  onTap: () => ref
                      .read(habitsProvider.notifier)
                      .toggleHabitToday(habit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isToday ? color : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2.5),
                    ),
                    child: isToday
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22)
                            .animate()
                            .scale(curve: Curves.elasticOut)
                        : Icon(Icons.add_rounded,
                            color: color, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // 21-day tracker
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Streak treker (21 kun maqsad)',
                    style: theme.textTheme.labelSmall),
                Text('${(progress * 100).toInt()}%',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _build21DayGrid(context, habit, color),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showCalendarDialog(context, habit),
                  icon: const Icon(Icons.calendar_month_rounded, size: 16),
                  label: const Text('Kalendar'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ref
                      .read(habitsProvider.notifier)
                      .deleteHabit(habit),
                  icon:
                      const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text("O'chirish"),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).slideY(
        begin: 0.2, curve: Curves.easeOut).fadeIn();
  }

  Widget _build21DayGrid(
      BuildContext context, h.HabitModel habit, Color color) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(21, (i) {
        final day = habit.createdAt.add(Duration(days: i));
        final isCompleted = habit.completedDates.any((d) =>
            d.year == day.year &&
            d.month == day.month &&
            d.day == day.day);
        final isPast = day.isBefore(DateTime.now());
        final isToday = day.day == DateTime.now().day &&
            day.month == DateTime.now().month &&
            day.year == DateTime.now().year;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? color
                : isPast
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14)
                : Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isPast
                          ? color.withOpacity(0.5)
                          : Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  void _showCalendarDialog(BuildContext context, h.HabitModel habit) {
    final color = AppColors.fromHex(habit.color);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${habit.emoji} ${habit.title} Kalendari',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TableCalendar(
                firstDay: habit.createdAt,
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) {
                  return habit.completedDates.any((d) =>
                          d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day)
                      ? [true]
                      : [];
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Yopish'),
              ),
            ],
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
          const Text('🔄', style: TextStyle(fontSize: 64))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('Hali odat yo\'q!',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '1-kundan boshlang, har kuni belgilang!',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddHabitSheet(
        onSave: (habit) =>
            ref.read(habitsProvider.notifier).addHabit(habit),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

// ==================== ADD HABIT SHEET ====================
class AddHabitSheet extends StatefulWidget {
  final Function(h.HabitModel) onSave;

  const AddHabitSheet({super.key, required this.onSave});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _titleController = TextEditingController();
  String _selectedEmoji = '⭐';
  String _selectedColor = '#6C63FF';
  TimeOfDay? _reminderTime;
  List<int> _selectedDays = [];

  final List<String> _emojis = [
    '⭐', '💪', '📚', '🏃', '💧', '🧘', '🍎', '😴',
    '🎯', '✍️', '🎵', '🌿', '🧠', '❤️', '🚴', '🌅',
  ];

  final List<String> _dayNames = [
    'Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'
  ];

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
      child: SingleChildScrollView(
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
            Text('🔄 Yangi odat', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),

            // Emoji picker
            Text('Emoji tanlang:', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Odat nomi *',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Color
            Text('Rang tanlang:', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: AppColors.habitColors.map((c) {
                final hex =
                    '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 8)
                            ]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Days
            Text("Takrorlanish kunlari (bo'sh = har kuni):",
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = i + 1;
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : theme.inputDecorationTheme.fillColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _dayNames[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Reminder
            GestureDetector(
              onTap: _pickReminderTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_rounded,
                        color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      _reminderTime != null
                          ? 'Eslatma: ${_reminderTime!.format(context)}'
                          : 'Eslatma vaqtini belgilash',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('1-kundan boshlash 🚀'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odat nomini kiriting!')),
      );
      return;
    }

    h.TimeOfDay? reminderTime;
    if (_reminderTime != null) {
      reminderTime = h.TimeOfDay(
          hour: _reminderTime!.hour, minute: _reminderTime!.minute);
    }

    final habit = h.HabitModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      emoji: _selectedEmoji,
      color: _selectedColor,
      repeatDays: _selectedDays,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
    );

    widget.onSave(habit);
    Navigator.pop(context);
  }
}
