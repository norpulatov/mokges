// lib/models/journal_model.dart

class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final String mood; // emoji
  final int moodScore; // 1-5
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    this.mood = '😊',
    this.moodScore = 3,
    this.tags = const [],
  });

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? content,
    String? mood,
    int? moodScore,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
      'moodScore': moodScore,
      'tags': tags.join(','),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    List<String> tags = [];
    if (map['tags'] != null && (map['tags'] as String).isNotEmpty) {
      tags = (map['tags'] as String).split(',');
    }
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      content: map['content'] as String,
      mood: map['mood'] as String? ?? '😊',
      moodScore: map['moodScore'] as int? ?? 3,
      tags: tags,
    );
  }
}
