// lib/screens/journal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_model.dart';
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kundalik 📔', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Fikr va his-tuyg\'ularingizni yozing',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppTheme.accent),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '📝 Bugungi qayd'),
                Tab(text: '📚 Barcha qaydlar'),
              ],
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TodayJournalTab(),
            _AllJournalsTab(),
          ],
        ),
      ),
    );
  }
}

// ==================== BUGUNGI QAYD ====================
class _TodayJournalTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TodayJournalTab> createState() => _TodayJournalTabState();
}

class _TodayJournalTabState extends ConsumerState<_TodayJournalTab> {
  final _contentController = TextEditingController();
  String _selectedMood = '😊';
  int _moodScore = 3;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😄', 'label': 'Ajoyib', 'score': 5},
    {'emoji': '😊', 'label': 'Yaxshi', 'score': 4},
    {'emoji': '😐', 'label': 'Normal', 'score': 3},
    {'emoji': '😔', 'label': 'Xafa', 'score': 2},
    {'emoji': '😢', 'label': 'Yomon', 'score': 1},
  ];

  final List<String> _quickTags = [
    '💪 Sport', '📚 O\'qish', '👨‍💼 Ish', '👨‍👩‍👧 Oila',
    '🎯 Maqsad', '🌱 O\'sish', '❤️ Muhabbat', '🙏 Minnatdorlik',
  ];

  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  void _loadTodayEntry() async {
    final entry = await ref.read(journalProvider.notifier).getTodayEntry();
    if (entry != null && mounted) {
      setState(() {
        _contentController.text = entry.content;
        _selectedMood = entry.mood;
        _moodScore = entry.moodScore;
        _selectedTags.clear();
        _selectedTags.addAll(entry.tags);
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Qaydingizdagi matnni kiriting')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final entry = JournalEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      content: _contentController.text.trim(),
      mood: _selectedMood,
      moodScore: _moodScore,
      tags: List.from(_selectedTags),
    );

    await ref.read(journalProvider.notifier).saveEntry(entry);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Qayd saqlandi!'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final dateStr = DateFormat('dd MMMM, yyyy').format(today);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Kayfiyat tanlash
          Text('Bugungi kayfiyatingiz?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['emoji'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedMood = mood['emoji'] as String;
                  _moodScore = mood['score'] as int;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood['emoji'] as String,
                          style: TextStyle(fontSize: isSelected ? 32 : 24)),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? AppTheme.primaryColor : null,
                          fontWeight: isSelected ? FontWeight.w700 : null,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 100.ms),

          const SizedBox(height: 24),

          // Tezkor teglar
          Text('Teglar', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTags.remove(tag);
                    } else {
                      _selectedTags.add(tag);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 24),

          // Matn yozish
          Text('Bugun nima bo\'ldi?', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 10,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText:
                    'Bugun nima his qildingiz? Nima o\'rgandingiz?\nKichik yutuqlaringizni ham yozing...',
                hintStyle: theme.textTheme.bodySmall?.copyWith(height: 1.8),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // Saqlash tugmasi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saqlanmoqda...' : 'Saqlash'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ==================== BARCHA QAYDLAR ====================
class _AllJournalsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider);
    final theme = Theme.of(context);

    return journalAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📔', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Hali qaydlar yo\'q',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Birinchi qaydingizni yozing!',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return _JournalCard(entry: entries[index], index: index);
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Xatolik: $e')),
    );
  }
}

class _JournalCard extends ConsumerWidget {
  final JournalEntry entry;
  final int index;

  const _JournalCard({required this.entry, required this.index});

  Color _getMoodColor(int score) {
    switch (score) {
      case 5:
        return const Color(0xFF43E97B);
      case 4:
        return AppTheme.accent;
      case 3:
        return AppTheme.warning;
      case 2:
        return AppTheme.secondary;
      case 1:
        return const Color(0xFFFF6584);
      default:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd MMMM, yyyy — HH:mm').format(entry.date);
    final moodColor = _getMoodColor(entry.moodScore);
    final isToday = () {
      final now = DateTime.now();
      return entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day;
    }();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: moodColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.mood, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(dateStr,
                            style: theme.textTheme.bodySmall),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Bugun',
                                style: TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < entry.moodScore
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: moodColor,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('O\'chirish?'),
                      content: const Text(
                          'Bu qaydni o\'chirmoqchimisiz?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Bekor qilish')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('O\'chirish',
                                style:
                                    TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(journalProvider.notifier)
                        .deleteEntry(entry.id);
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: Colors.red.withOpacity(0.5),
              ),
            ],
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: entry.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: moodColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 80)).slideY(begin: 0.2).fadeIn();
  }
}
