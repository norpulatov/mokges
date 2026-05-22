# 📱 Mokges — Aqlli Kunlik Rejalashtiruvchi

> Kunlik ishlar, odat shakllantirish va sog'lom hayot uchun zamonaviy Flutter ilovasi

---

## 🚀 Xususiyatlar

| Bo'lim | Imkoniyatlar |
|--------|-------------|
| 📋 **Kunlik ishlar** | Qo'shish, tahrirlash, o'chirish, vaqt belgilash, kechiktirish (snooze), konfeti animatsiyasi |
| 🔄 **Odatlar** | 21-kunlik treker, streak (zanjir), kalendar ko'rinishi, eslatmalar |
| 🌿 **Sog'lom hayot** | Ilmiy faktlar, jismoniy mashqlar, nafas olish (4-7-8), motivatsion iqtiboslar |
| 🤖 **AI Maslahat** | OpenAI API yoki offline tayyor maslahatlar bazasi |
| 📊 **Statistika** | Haftalik grafik, streak rekordi, samaradorlik foizi |
| 📱 **Vidjet** | Uy ekraniga 4×2 vidjet (bugungi 3 ta ish) |

---

## ⚙️ O'rnatish

### Talablar
- Flutter 3.13+
- Dart 3.0+
- Android Studio yoki VS Code
- Android 5.0+ yoki iOS 12+

### 1. Loyihani klonlash
```bash
git clone https://github.com/yourusername/mokges.git
cd mokges
```

### 2. Paketlarni o'rnatish
```bash
flutter pub get
```

### 3. Kodni generatsiya qilish (Riverpod)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Ilovani ishga tushirish
```bash
flutter run
```

---

## 🤖 AI Maslahat — API Kalitini Sozlash

### OpenAI API kaliti olish:
1. https://platform.openai.com saytiga kiring
2. "API Keys" bo'limiga o'ting
3. Yangi kalit yarating (`sk-...` bilan boshlanadi)

### Ilovada sozlash:
1. Ilovani oching
2. Pastki panelda **⚙️ Sozlamalar** ga bosing
3. "OpenAI API Kaliti" maydoniga kalitingizni kiriting
4. "Saqlash" tugmasini bosing

> **Eslatma:** API kaliti bo'lmasa, ilova avtomatik ravishda offline maslahatlar bazasidan foydalanadi. Bu ham juda yaxshi ishlaydi!

---

## 📱 Android Vidjetini Ulash

### AndroidManifest.xml ga qo'shish:
`android/app/src/main/AndroidManifest.xml` faylida `<application>` tagi ichiga:

```xml
<receiver android:name=".MokgesWidget"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/mokges_widget_info" />
</receiver>
```

Va ruxsatlarni qo'shing:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Vidjetni telefonga qo'shish:
1. Uy ekranida bo'sh joyga uzoq bosing
2. "Vidjetlar" ni tanlang
3. "Mokges" ni toping
4. 4×2 yoki 2×2 o'lchamda qo'ying

---

## 📂 Loyiha Tuzilishi

```
lib/
├── main.dart                  # Asosiy kirish nuqtasi
├── models/
│   ├── task_model.dart        # Vazifa modeli
│   └── habit_model.dart       # Odat modeli
├── providers/
│   └── app_providers.dart     # Riverpod provayderlar
├── screens/
│   ├── tasks_screen.dart      # Kunlik ishlar ekrani
│   ├── habits_screen.dart     # Odatlar trekeri
│   ├── health_screen.dart     # Sog'lom hayot + AI
│   ├── stats_screen.dart      # Statistika
│   └── settings_screen.dart   # Sozlamalar
├── services/
│   ├── database_service.dart  # SQLite baza
│   ├── ai_service.dart        # AI maslahatlar
│   ├── notification_service.dart # Bildirishnomalar
│   └── widget_service.dart    # Uy ekrani vidjeti
└── utils/
    └── app_theme.dart         # Tema va ranglar

android/
├── app/src/main/
│   ├── kotlin/.../MokgesWidget.kt   # Widget receiver
│   ├── res/layout/mokges_widget.xml  # Widget ko'rinishi
│   └── res/xml/mokges_widget_info.xml # Widget sozlamalari
```

---

## 🎨 Texnologiyalar

| Paket | Maqsad |
|-------|--------|
| `flutter_riverpod` | Holat boshqaruvi |
| `sqflite` | Ma'lumotlar bazasi |
| `flutter_local_notifications` | Eslatmalar |
| `home_widget` | Uy ekrani vidjeti |
| `fl_chart` | Statistika grafiklari |
| `table_calendar` | Odat kalendari |
| `flutter_animate` | Animatsiyalar |
| `confetti` | Ish bajarilganda konfeti |
| `google_fonts` | Poppins shrift |
| `http` | OpenAI API ulanishi |

---

## 🌟 Kelajakdagi xususiyatlar

- [ ] Google Calendar sinxronizatsiyasi
- [ ] Gemini API integratsiyasi
- [ ] Bulut sinxronizatsiyasi
- [ ] Widget konfiguratsiyasi
- [ ] Batafsil statistika
- [ ] O'zbek tili to'liq lokalizatsiyasi

---

## 📄 Litsenziya

MIT License © 2024 Mokges

---

**❤️ Sizning samarali va sog'lom hayotingiz uchun yaratildi!**
