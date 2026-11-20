import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/catalog_models.dart';

class CatalogRepository {
  const CatalogRepository();

  Future<CatalogBundle> load() async {
    final sources = await Future.wait([
      rootBundle.loadString('assets/data/vocabulary_catalog.json'),
      rootBundle.loadString('assets/data/lesson_catalog.json'),
    ]);
    final vocabularyJson = jsonDecode(sources[0]) as Map<String, dynamic>;
    final lessonJson = jsonDecode(sources[1]) as Map<String, dynamic>;
    final vocabulary = <String, VocabularyEntry>{
      for (final raw in vocabularyJson['items'] as List<dynamic>)
        (raw as Map<String, dynamic>)['id'] as String: VocabularyEntry.fromJson(
          raw,
        ),
    };
    final lessons = (lessonJson['lessons'] as List<dynamic>)
        .map((raw) => LessonDefinition.fromJson(raw as Map<String, dynamic>))
        .where(
          (lesson) =>
              lesson.vocabularyIds
                  .where((id) => vocabulary[id]?.isPlayable ?? false)
                  .length >=
              4,
        )
        .toList(growable: false);
    return CatalogBundle(vocabulary: vocabulary, lessons: lessons);
  }
}

class CatalogBundle {
  const CatalogBundle({required this.vocabulary, required this.lessons});
  final Map<String, VocabularyEntry> vocabulary;
  final List<LessonDefinition> lessons;
  List<VocabularyEntry> playableFor(LessonDefinition lesson) => lesson
      .vocabularyIds
      .map((id) => vocabulary[id])
      .whereType<VocabularyEntry>()
      .where((item) => item.isPlayable)
      .toList(growable: false);
}
