// lib/screens/stats_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final tasksAsync = ref.watch(tasksProvider);

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
                    Text('Statistika 📊',
                        style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Sizning taraqqiyotingiz',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overview cards
                habitsAsync.when(
                  data: (habits) => tasksAsync.when(
                    data: (tasks) =>
                        _buildOverviewCards(context, habits, tasks),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 24),

                // Weekly bar chart
                Text('Haftalik bajarilgan ishlar',
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
                weeklyStats.when(
                  data: (stats) =>
                      _buildWeeklyChart(context, stats),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (e, _) => Text('Xatolik: $e'),
                ),

                const SizedBox(height: 24),

                // Habits progress
                Text('Odatlar holati 🔄',
                    style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
                habitsAsync.when(
                  data: (habits) =>
                      _buildHabitsProgress(context, habits),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('$e'),
                ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(
      BuildContext context, List habits, List tasks) {
    final totalCompleted =
        tasks.where((t) => t.isCompleted).length;
    final bestStreak = habits.isEmpty
        ? 0
        : habits
            .map((h) => h.currentStreak)
            .reduce((a, b) => a > b ? a : b);
    final totalHabits = habits.length;
    final completedHabitsToday =
        habits.where((h) => h.isCompletedToday()).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          emoji: '✅',
          title: 'Bugun bajarildi',
          value: '$totalCompleted',
          subtitle: 'ta ish',
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF9B95FF)],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
        _StatCard(
          emoji: '🔥',
          title: 'Eng uzun streak',
          value: '$bestStreak',
          subtitle: 'kun',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6584), Color(0xFFFFB347)],
          ),
        ).animate().scale(delay: 100.ms, duration: 400.ms),
        _StatCard(
          emoji: '🎯',
          title: 'Odatlar',
          value: '$completedHabitsToday/$totalHabits',
          subtitle: 'bugun',
          gradient: const LinearGradient(
            colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms),
        _StatCard(
          emoji: '⚡',
          title: 'Samaradorlik',
          value: tasks.isEmpty
              ? '0%'
              : '${(totalCompleted / tasks.length * 100).toInt()}%',
          subtitle: 'bajarildi',
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB347), Color(0xFFF7971E)],
          ),
        ).animate().scale(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context, Map<String, int> stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entries = stats.entries.toList();

    if (entries.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: Text('Ma\'lumot yo\'q')),
      );
    }

    final maxY =
        (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b))
            .toDouble()
            .clamp(1, double.infinity);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withOpacity(0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxY + 1) {
                    return const SizedBox();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.labelSmall,
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        entries[index].key,
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final isMax = entry.value.value ==
                entries
                    .map((e) => e.value)
                    .reduce((a, b) => a > b ? a : b);
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  gradient: LinearGradient(
                    colors: isMax
                        ? [AppTheme.primaryColor, const Color(0xFF9B95FF)]
                        : [
                            AppTheme.primaryColor.withOpacity(0.5),
                            AppTheme.primaryColor.withOpacity(0.3),
                          ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildHabitsProgress(BuildContext context, List habits) {
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text('Hali odat qo\'shilmagan'),
        ),
      );
    }

    return Column(
      children: habits.asMap().entries.map((entry) {
        final habit = entry.value;
        final color = AppColors.fromHex(habit.color);
        final progress = habit.completionFor21Days;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(habit.emoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(habit.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium),
                        Row(
                          children: [
                            const Icon(
                                Icons.local_fire_department_rounded,
                                size: 14,
                                color: Colors.orange),
                            Text(
                              ' ${habit.currentStreak}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: Colors.orange,
                                      fontWeight:
                                          FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '21 kunlik treker: ${(progress * 100).toInt()}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: entry.key * 80)).slideX(
            begin: 0.2, curve: Curves.easeOut).fadeIn();
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final Gradient gradient;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
