// lib/services/ai_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  // OpenAI API kalitini bu yerga yozing yoki SharedPreferences dan oling
  String? _openAiKey;

  void setApiKey(String key) {
    _openAiKey = key;
  }

  // ==================== OFFLINE MASLAHATLAR ====================
  static const List<String> _offlineTips = [
    "🌅 Ertalabki mashg'ulotlar miyangizni butun kun davomida faol ushlab turadi. Bugun 10 daqiqa jismoniy mashq qiling!",
    "💧 Har kuni kamida 8 stakan suv iching. Tanangizning 60% suvdan iborat!",
    "😴 Ilm-fan isbotladi: 7-8 soat uyqu xotira va ijodkorlikni 40% ga oshiradi.",
    "🧘 Chuqur nafas olish mashqi (4-7-8): 4 soniya nafas oling, 7 soniya ushlab turing, 8 soniyada chiqaring.",
    "📚 Yangi odat o'rtacha 66 kunda shakllanadi — 21 kun faqat boshlash uchun!",
    "🏃 Kun davomida 30 daqiqa yurish yurak kasalligini 35% ga kamaytiradi.",
    "🍎 Tushlikdan oldin salat yesangiz, umumiy kaloriya iste'molingiz 20% ga kamayadi.",
    "📵 Uxlashdan 1 soat oldin telefonni qo'ying — melatonin ishlab chiqarilishi yaxshilanadi.",
    "✅ Eng muhim ishni ertalab birinchi navbatda bajaring — bu 'Qurbaqani yeb oling' tamoyili!",
    "🔁 Odatlarni zanjirga bog'lang: 'Kofeni ichganimdan keyin daftarimni yozaman'.",
    "🎯 Har kuni 3 ta asosiy maqsad belgilang — ko'p emas, lekin aniq.",
    "🌿 Tabiatda 20 daqiqa o'tirish stress gormonini 21% ga kamaytiradi.",
    "💪 Kichik g'alabalar katta motivatsiya beradi — bugun bitta ishni tugatib quvoning!",
    "🧠 Multitasking miyangizni 40% ga samarasizlashtiradi. Bir ish — bir vaqt!",
    "⏰ Pomodoro texnikasi: 25 daqiqa ish, 5 daqiqa dam — bu usul samaradorlikni oshiradi.",
    "🌙 Kechqurun rejangizni tuzib qo'ying — ertalab 10 daqiqa tejaladi.",
    "🤝 Odatingizni do'stingizga aytib qo'ying — mas'uliyat hissi 65% muvaffaqiyat ehtimolini oshiradi.",
    "📊 O'z taraqqiyotingizni kuzatib boring — ko'rish motivatsiyani ikki barobar oshiradi.",
    "🎵 Instrumental musiqa eshitib ishlash konsentratsiyani 14% ga oshiradi.",
    "🙏 Har kuni 3 ta minnatdorlik narsa yozing — bu baxtni klinik jihatdan isbotlangan usulda oshiradi.",
  ];

  static const List<String> _streakMessages = [
    "🔥 Zo'r! Ketma-ket {days} kun odatingizni bajarayapsiz! Davom eting!",
    "⭐ {days} kunlik streak — siz ajoyibsiz! Ertaga ham unuting!",
    "💪 {days} kun — bu odatga aylana boshladi! Miyangiz yangilanmoqda!",
    "🏆 {days} kunlik zanjir — bu rekordga yaqinlashmoqda!",
  ];

  String getStreakMessage(int days) {
    final rnd = Random();
    final msg = _streakMessages[rnd.nextInt(_streakMessages.length)];
    return msg.replaceAll('{days}', days.toString());
  }

  String getRandomTip() {
    final rnd = Random();
    return _offlineTips[rnd.nextInt(_offlineTips.length)];
  }

  String getPersonalizedTip({
    required int totalTasksCompleted,
    required int totalHabitsToday,
    required int bestStreak,
    required String mostProductiveTime,
  }) {
    if (totalTasksCompleted == 0) {
      return "🌟 Bugun birinchi ishingizni bajaring! Har bir katta sayohat bitta qadamdan boshlanadi.";
    }
    if (totalHabitsToday == 0) {
      return "⚡ Bugun hali odat bajarmaganingiz ko'rinib turibdi. Keling, hoziroq boshlaylik!";
    }
    if (bestStreak > 7) {
      return "🔥 ${bestStreak} kunlik rekordingiz bor! Bu haqiqiy odatga aylanmoqda. Ilm-fan isbotladi: siz to'g'ri yo'ldasiz!";
    }
    if (mostProductiveTime == 'morning') {
      return "🌅 Siz ertalab eng samarali ekansiz! Eng muhim ishlarni soat 9-11 oralig'iga rejalashtiring.";
    }
    return getRandomTip();
  }

  // ==================== OPENAI API ====================
  Future<String> getAiAdvice({
    required List<String> habitNames,
    required int completedTasks,
    required int totalStreak,
  }) async {
    if (_openAiKey == null || _openAiKey!.isEmpty) {
      return getRandomTip();
    }

    try {
      final prompt = """
Foydalanuvchi quyidagi ma'lumotlarga ega:
- Odatlari: ${habitNames.join(', ')}
- So'nggi 7 kunda bajarilgan ishlar: $completedTasks
- Umumiy streak: $totalStreak kun

Unga qisqa (2-3 jumlali), ilmiy asosli, rag'batlantiruvchi maslahat ber.
Maslahatni o'zbek tilida ber. Emoji ishlat.
""";

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Sen o\'zbek tilida gaplashuvchi shaxsiy produktivlik va sog\'lom hayot bo\'yicha maslahatchi assistantsan.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return getRandomTip();
      }
    } catch (e) {
      return getRandomTip();
    }
  }
}
