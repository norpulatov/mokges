// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/ai_service.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Ko\'rinish'),
          _SettingCard(
            child: SwitchListTile(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state =
                    val ? ThemeMode.dark : ThemeMode.light;
              },
              title: Text('Dark Mode', style: theme.textTheme.titleMedium),
              subtitle: Text('Qorong\'u mavzu',
                  style: theme.textTheme.bodySmall),
              secondary:
                  const Icon(Icons.dark_mode_rounded, color: AppTheme.primaryColor),
              activeColor: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: '🤖 AI Sozlamalari'),
          _SettingCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key_rounded,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text('OpenAI API Kaliti',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu kalit bo\'lmasa, offline maslahatlar ishlaydi.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      hintText: 'sk-...',
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded),
                        onPressed: () =>
                            setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final key = _apiKeyController.text.trim();
                        AiService().setApiKey(key);
                        ref.read(aiKeyProvider.notifier).state = key;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ API kaliti saqlandi!')),
                        );
                      },
                      child: const Text('Saqlash'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: '📱 Ilova haqida'),
          _SettingCard(
            child: ListTile(
              leading: const Text('📱', style: TextStyle(fontSize: 28)),
              title: Text('Mokges', style: theme.textTheme.titleMedium),
              subtitle: Text('Versiya 1.0.0', style: theme.textTheme.bodySmall),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Bepul',
                    style: TextStyle(
                        color: AppTheme.accent, fontWeight: FontWeight.w700)),
              ),
            ),
          ),

          _SettingCard(
            child: ListTile(
              leading: const Icon(Icons.widgets_rounded,
                  color: AppTheme.primaryColor),
              title: Text('Uy ekrani vidjeti',
                  style: theme.textTheme.titleMedium),
              subtitle: Text(
                  'Vidjetni qo\'shish uchun ekranda uzoq bosib turing',
                  style: theme.textTheme.bodySmall),
            ),
          ),

          const SizedBox(height: 40),

          // About box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF9B95FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: const [
                Text('📱 Mokges',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text(
                  'Kunlik ishlar, odatlar va sog\'lom hayot\nuchun aqlli yordamchi',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
                SizedBox(height: 12),
                Text('❤️ Sizning samarali hayotingiz uchun yaratildi',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
