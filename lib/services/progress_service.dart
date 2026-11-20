import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WordProgress {
  const WordProgress({
    this.seen = 0,
    this.correct = 0,
    this.wrong = 0,
    this.lastReviewed,
  });
  final int seen;
  final int correct;
  final int wrong;
  final DateTime? lastReviewed;
  bool get needsReview => wrong > correct || (seen > 0 && correct < 2);
  WordProgress record(bool wasCorrect) => WordProgress(
    seen: seen + 1,
    correct: correct + (wasCorrect ? 1 : 0),
    wrong: wrong + (wasCorrect ? 0 : 1),
    lastReviewed: DateTime.now(),
  );
  Map<String, dynamic> toJson() => {
    'seen': seen,
    'correct': correct,
    'wrong': wrong,
    'lastReviewed': lastReviewed?.toIso8601String(),
  };
  factory WordProgress.fromJson(Map<String, dynamic> json) => WordProgress(
    seen: json['seen'] as int? ?? 0,
    correct: json['correct'] as int? ?? 0,
    wrong: json['wrong'] as int? ?? 0,
    lastReviewed: json['lastReviewed'] == null
        ? null
        : DateTime.tryParse(json['lastReviewed'] as String),
  );
}

class ProgressService {
  const ProgressService();
  static const _progressKey = 'word_progress_v2';
  static const _stickersKey = 'stickers_v2';
  static const _lessonsKey = 'completed_lessons_v2';
  Future<Map<String, WordProgress>> loadWordProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return {};
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map(
      (key, value) =>
          MapEntry(key, WordProgress.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<void> recordAnswer(String id, bool correct) async {
    final all = await loadWordProgress();
    all[id] = (all[id] ?? const WordProgress()).record(correct);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _progressKey,
      jsonEncode(all.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<Set<String>> loadStickers() async =>
      (await SharedPreferences.getInstance())
          .getStringList(_stickersKey)
          ?.toSet() ??
      <String>{};
  Future<void> awardSticker(String id) async {
    final all = await loadStickers()
      ..add(id);
    await (await SharedPreferences.getInstance()).setStringList(
      _stickersKey,
      all.toList(),
    );
  }

  Future<Set<String>> completedLessons() async =>
      (await SharedPreferences.getInstance())
          .getStringList(_lessonsKey)
          ?.toSet() ??
      <String>{};
  Future<void> completeLesson(String id) async {
    final all = await completedLessons()
      ..add(id);
    await (await SharedPreferences.getInstance()).setStringList(
      _lessonsKey,
      all.toList(),
    );
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_progressKey),
      prefs.remove(_stickersKey),
      prefs.remove(_lessonsKey),
    ]);
  }
}
