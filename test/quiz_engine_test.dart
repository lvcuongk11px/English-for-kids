import 'dart:math';

import 'package:english_for_kids/models/topic.dart';
import 'package:english_for_kids/models/vocabulary_item.dart';
import 'package:english_for_kids/services/quiz_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Topic topicWith(int count) => Topic(
  id: 'test',
  englishName: 'Test',
  vietnameseName: 'Thử',
  coverImagePath: 'cover.png',
  accentColor: 0xFF000000,
  items: List.generate(
    count,
    (index) => VocabularyItem(
      id: 'item$index',
      word: 'word$index',
      questionText: 'Question $index?',
      imagePath: 'image$index.png',
      questionAudioPath: 'audio$index.wav',
    ),
  ),
);

void main() {
  test('quiz creates up to ten unique questions with four unique choices', () {
    final questions = QuizEngine(random: Random(7))
        .createSession(topicWith(12));
    expect(questions, hasLength(10));
    expect(
      questions.map((question) => question.answer.id).toSet(),
      hasLength(10),
    );
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.map((item) => item.id).toSet(), hasLength(4));
      expect(
        question.options.where((item) => item.id == question.answer.id),
        hasLength(1),
      );
    }
  });
  test(
    'quiz rejects topics that cannot provide four choices',
    () => expect(
      () => QuizEngine().createSession(topicWith(3)),
      throwsArgumentError,
    ),
  );
}
