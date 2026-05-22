// lib/screens/health_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_providers.dart';
import '../utils/app_theme.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  // Nafas olish mashqi
  bool _isBreathing = false;
  String _breathPhase = '';
  int _breathCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                    Text('Sog\'lom Hayot 🌿',
                        style: theme.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Ilmiy maslahatlar va AI yordamchi',
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
                Tab(text: '🤖 AI Maslahat'),
                Tab(text: '💪 Mashqlar'),
                Tab(text: '🧠 Ilm-fan'),
              ],
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAiTab(context),
            _buildExercisesTab(context),
            _buildScienceTab(context),
          ],
        ),
      ),
    );
  }

  // ==================== AI TAB ====================
  Widget _buildAiTab(BuildContext context) {
    final theme = Theme.of(context);
    final aiAdviceAsync = ref.watch(aiAdviceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // AI Advice Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B95FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🤖',
                            style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AI Yordamchi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Shaxsiy tahlil',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                aiAdviceAsync.when(
                  data: (advice) => Text(
                    advice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  loading: () => const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Tahlil qilinmoqda...',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  error: (e, _) => const Text(
                    'Maslahat yuklab olishda xato yuz berdi',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(aiAdviceProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Yangilash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.3).fadeIn(),

          const SizedBox(height: 24),

          // Nafas olish mashqi
          Text('🫁 Nafas Olish Mashqi (4-7-8)',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildBreathingExercise(context),

          const SizedBox(height: 24),

          // Motivational quotes
          Text('💬 Kunlik Ilhom', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildMotivationalQuotes(context),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBreathingExercise(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            '4-7-8 usuli stress va bezovtalikni kamaytiradi',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            width: _isBreathing ? 140 : 100,
            height: _isBreathing ? 140 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.8),
                  AppTheme.accent.withOpacity(0.2),
                ],
              ),
              boxShadow: _isBreathing
                  ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                _isBreathing ? _breathPhase : '🫁',
                style: const TextStyle(
                    fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_breathCount > 0)
            Text('Tsikl: $_breathCount / 4',
                style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isBreathing ? null : _startBreathing,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
                _isBreathing ? 'Davom etmoqda...' : 'Boshlash'),
          ),
        ],
      ),
    );
  }

  void _startBreathing() async {
    setState(() {
      _isBreathing = true;
      _breathCount = 0;
    });

    for (int cycle = 0; cycle < 4; cycle++) {
      if (!mounted) return;
      setState(() {
        _breathCount = cycle + 1;
        _breathPhase = 'Nafas\noling\n4 son';
      });
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;
      setState(() => _breathPhase = 'Ushlab\nturing\n7 son');
      await Future.delayed(const Duration(seconds: 7));

      if (!mounted) return;
      setState(() => _breathPhase = 'Chiqaring\n8 son');
      await Future.delayed(const Duration(seconds: 8));
    }

    if (!mounted) return;
    setState(() {
      _isBreathing = false;
      _breathPhase = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ Nafas olish mashqi tugadi! Yaxshi bo\'ling!')),
    );
  }

  Widget _buildMotivationalQuotes(BuildContext context) {
    final quotes = [
      {
        'text': 'Kichik qadamlar katta o\'zgarishlarga olib keladi.',
        'author': 'Lao Tzu'
      },
      {
        'text': 'Bugun qilgan narsangiz ertangi taqdirni belgilaydi.',
        'author': 'Konfutsiy'
      },
      {
        'text':
            'Muvaffaqiyat bir kecha-kunduzda kelib qolmaydi — u har kuni quriladi.',
        'author': 'Unknown'
      },
    ];

    final today = DateTime.now().day % quotes.length;
    final quote = quotes[today];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6584), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('"',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 0.8)),
          Text(
            quote['text']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '— ${quote['author']}',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms);
  }

  // ==================== EXERCISES TAB ====================
  // Haftalik mashqlar jadvali — 7 kun, har kuni boshqacha, takrorlanadi
  static const List<List<Map<String, dynamic>>> _weeklyExercises = [
    // Dushanba — Ko'krak + Qo'l
    [
      {'name': 'Push-up', 'emoji': '💪', 'sets': '4 × 12 marta', 'desc': 'Ko\'krak va qo\'l mushaklarini kuchaytiradi. Orqa tik bo\'lsin.', 'color': 0xFF6C63FF},
      {'name': 'Tricep Dips', 'emoji': '🪑', 'sets': '3 × 10 marta', 'desc': 'Stulda yoki yerda — triceps mushaklari uchun.', 'color': 0xFF9B95FF},
      {'name': 'Plank', 'emoji': '🏋️', 'sets': '3 × 40 soniya', 'desc': 'Core mushaklarini mustahkamlaydi.', 'color': 0xFF38F9D7},
      {'name': 'Cho\'zilish', 'emoji': '🧘', 'sets': '5 daqiqa', 'desc': 'Mushaklar elastikligini oshiradi.', 'color': 0xFF43E97B},
    ],
    // Seshanba — Oyoq
    [
      {'name': 'Squat', 'emoji': '🦵', 'sets': '4 × 15 marta', 'desc': 'Oyoq va dumg\'aza mushaklarini rivojlantiradi.', 'color': 0xFFFF6584},
      {'name': 'Lunges', 'emoji': '🚶', 'sets': '3 × 12 marta (har oyoq)', 'desc': 'Muvozanat va oyoq kuchini oshiradi.', 'color': 0xFFFFB347},
      {'name': 'Calf Raises', 'emoji': '🦶', 'sets': '3 × 20 marta', 'desc': 'Boldirni kuchaytiradi. Panjada turing.', 'color': 0xFFFF6B6B},
      {'name': 'Cho\'zilish', 'emoji': '🧘', 'sets': '5 daqiqa', 'desc': 'Oyoq mushaklarini bo\'shashtiring.', 'color': 0xFF43E97B},
    ],
    // Chorshanba — Kardio + Nafas
    [
      {'name': 'Jogging / Yurish', 'emoji': '🏃', 'sets': '25-30 daqiqa', 'desc': 'Yurak-tomir sog\'ligini yaxshilaydi, kaloriya yoqadi.', 'color': 0xFFFF9F43},
      {'name': 'Jumping Jacks', 'emoji': '⭐', 'sets': '3 × 30 marta', 'desc': 'Butun tanani isitadi, energiya beradi.', 'color': 0xFFFECA57},
      {'name': '4-7-8 Nafas', 'emoji': '🫁', 'sets': '4 tsikl', 'desc': 'Stress kamaytiradi, uyqu yaxshilaydi.', 'color': 0xFF48DBFB},
      {'name': 'Meditatsiya', 'emoji': '🧠', 'sets': '10 daqiqa', 'desc': 'Kortizolni kamaytiradi, diqqatni oshiradi.', 'color': 0xFF6C63FF},
    ],
    // Payshanba — Yelka + Orqa
    [
      {'name': 'Pike Push-up', 'emoji': '🔺', 'sets': '3 × 10 marta', 'desc': 'Yelka mushaklarini rivojlantiradi.', 'color': 0xFF5F27CD},
      {'name': 'Superman', 'emoji': '🦸', 'sets': '3 × 12 marta', 'desc': 'Orqa mushaklarini kuchaytiradi. Yerda yoting.', 'color': 0xFF0652DD},
      {'name': 'Side Plank', 'emoji': '↔️', 'sets': '2 × 30 soniya (har tomon)', 'desc': 'Yon mushaklarni (oblique) mustahkamlaydi.', 'color': 0xFF1289A7},
      {'name': 'Cho\'zilish', 'emoji': '🧘', 'sets': '5 daqiqa', 'desc': 'Yelka va orqani bo\'shashtiring.', 'color': 0xFF43E97B},
    ],
    // Juma — Qorin
    [
      {'name': 'Crunch', 'emoji': '🎯', 'sets': '4 × 20 marta', 'desc': 'Qorin mushaklarini rivojlantiradi.', 'color': 0xFFFF6584},
      {'name': 'Leg Raises', 'emoji': '🦵', 'sets': '3 × 15 marta', 'desc': 'Pastki qorin mushaklari uchun.', 'color': 0xFFFF9F43},
      {'name': 'Mountain Climbers', 'emoji': '🏔️', 'sets': '3 × 20 marta', 'desc': 'Kardio + core — ikkalasini birga.', 'color': 0xFF6C63FF},
      {'name': 'Plank', 'emoji': '🏋️', 'sets': '3 × 45 soniya', 'desc': 'Qorinni mustahkamlab yakunlang.', 'color': 0xFF38F9D7},
    ],
    // Shanba — Butun tana (yengil)
    [
      {'name': 'Squat + Press', 'emoji': '💫', 'sets': '3 × 12 marta', 'desc': 'Qo\'llar tepaga ko\'tariladi — oyoq va yelka.', 'color': 0xFFFF9F43},
      {'name': 'Burpee', 'emoji': '🔥', 'sets': '3 × 8 marta', 'desc': 'Butun tanani ishlatadigan intensiv mashq.', 'color': 0xFFFF6584},
      {'name': 'Push-up', 'emoji': '💪', 'sets': '2 × 10 marta', 'desc': 'Ko\'krakni yakunlovchi mashq sifatida.', 'color': 0xFF6C63FF},
      {'name': 'Yurish', 'emoji': '🚶', 'sets': '15-20 daqiqa', 'desc': 'Tana tiklanishiga yordam beradi.', 'color': 0xFF43E97B},
    ],
    // Yakshanba — Dam olish + Cho'zilish
    [
      {'name': 'Yoga Cho\'zilish', 'emoji': '🧘', 'sets': '15 daqiqa', 'desc': 'Butun haftaning mushaklarini bo\'shashtiradi.', 'color': 0xFF6C63FF},
      {'name': 'Cat-Cow Yoga', 'emoji': '🐱', 'sets': '2 × 10 marta', 'desc': 'Umurtqa pog\'onasiga yaxshi ta\'sir qiladi.', 'color': 0xFF9B95FF},
      {'name': 'Child\'s Pose', 'emoji': '🌸', 'sets': '2 daqiqa', 'desc': 'Orqani bo\'shashtiradigan dam olish pozasi.', 'color': 0xFFFF6584},
      {'name': 'Nafas + Meditatsiya', 'emoji': '🌿', 'sets': '10 daqiqa', 'desc': 'Keyingi haftaga tayyorlanish uchun.', 'color': 0xFF43E97B},
    ],
  ];

  static const List<String> _dayNames = [
    'Dushanba', 'Seshanba', 'Chorshanba',
    'Payshanba', 'Juma', 'Shanba', 'Yakshanba'
  ];

  static const List<String> _dayFocus = [
    'Ko\'krak + Qo\'l 💪', 'Oyoq 🦵', 'Kardio + Nafas 🏃',
    'Yelka + Orqa 🔺', 'Qorin 🎯', 'Butun tana 🔥', 'Dam olish 🌿'
  ];

  Widget _buildExercisesTab(BuildContext context) {
    final theme = Theme.of(context);
    // Haftaning kuni: weekday 1=Mon...7=Sun → index 0..6
    final todayIndex = DateTime.now().weekday - 1;
    // Takrorlanuvchi hafta: ixtiyoriy kundan boshlab
    final weekIndex = todayIndex % 7;
    final todayExercises = _weeklyExercises[weekIndex];
    final dayName = _dayNames[weekIndex];
    final dayFocus = _dayFocus[weekIndex];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bugungi kun header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9B95FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugun: $dayName',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayFocus,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.3).fadeIn(),

        const SizedBox(height: 16),

        // Haftalik mini-jadval
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Haftalik jadval', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final isToday = i == weekIndex;
                  final labels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
                  final dayEmojis = ['💪', '🦵', '🏃', '🔺', '🎯', '🔥', '🌿'];
                  return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(dayEmojis[i],
                              style: TextStyle(fontSize: isToday ? 18 : 14)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
                          color: isToday ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        Text('Bugungi mashqlar', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),

        ...todayExercises.asMap().entries.map((e) {
          return _buildExerciseCard(context, e.value, e.key);
        }),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, Map<String, dynamic> exercise, int index) {
    final theme = Theme.of(context);
    final color = Color(exercise['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(exercise['emoji']! as String,
                  style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise['name']! as String,
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise['sets']! as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(exercise['desc']! as String,
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 100)).slideX(
        begin: 0.3, curve: Curves.easeOut).fadeIn();
  }

  // ==================== SCIENCE TAB ====================
  Widget _buildScienceTab(BuildContext context) {
    final facts = [
      {
        'emoji': '🧠',
        'title': 'Odat shakllantirish',
        'fact':
            'Olimlar yangi odat o\'rtacha 66 kunda shakllanishini isbotlagan (Phillippa Lally tadqiqoti, 2010). Ko\'p odamlar 21 kunni o\'ylaydi, lekin bu mif!',
        'color': AppTheme.primaryColor,
      },
      {
        'emoji': '😴',
        'title': 'Uyqu va miya',
        'fact':
            'Uyqu paytida miya xotira va bilimlarni qayta ishlaydi. 7-9 soat uyqu kognitiv funksiyani 40% oshiradi (Harvard tadqiqoti).',
        'color': const Color(0xFF6A85B6),
      },
      {
        'emoji': '💧',
        'title': 'Suv ichishning ahamiyati',
        'fact':
            'Tananing atigi 2% suv kamayishi konsentratsiyani 20% ga pasaytiradi. Har 2 soatda bir stakan suv ichi!',
        'color': const Color(0xFF38F9D7),
      },
      {
        'emoji': '🏃',
        'title': 'Jismoniy faollik',
        'fact':
            'Kun davomida 30 daqiqa yurish depressiya xavfini 35% ga, yurak kasalligi xavfini 40% ga kamaytiradi (WHO ma\'lumoti).',
        'color': AppTheme.accent,
      },
      {
        'emoji': '🎯',
        'title': 'Maqsad qo\'yish',
        'fact':
            'Maqsadlarni yozib qo\'ygan odamlar uni 42% ko\'proq amalga oshiradi (Dr. Gail Matthews tadqiqoti). Bugun yozing!',
        'color': AppTheme.warning,
      },
      {
        'emoji': '📵',
        'title': 'Telefon va uyqu',
        'fact':
            'Uxlashdan 1 soat oldin ekranga qaramaslik melatonin ishlab chiqarilishini 2 barobarga oshiradi va uyqu sifatini yaxshilaydi.',
        'color': AppTheme.secondary,
      },
      {
        'emoji': '🧘',
        'title': 'Meditatsiya',
        'fact':
            'Har kuni 10 daqiqa meditatsiya stress gormonini (kortizol) 23% ga kamaytiradi va immunitetni mustahkamlaydi.',
        'color': const Color(0xFF43E97B),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final fact = facts[index];
        final color = fact['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(fact['emoji']!,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fact['title']!,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                fact['fact']!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: index * 80)).fadeIn();
      },
    );
  }
}
