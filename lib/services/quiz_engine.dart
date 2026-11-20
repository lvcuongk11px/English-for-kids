import 'dart:math';

import '../models/quiz_question.dart';
import '../models/topic.dart';

class QuizEngine {
  QuizEngine({Random? random}) : _random = random ?? Random();
  final Random _random;

  List<QuizQuestion> createSession(Topic topic, {int maximumQuestions = 10}) {
    if (topic.items.length < 4) {
      throw ArgumentError('A topic needs at least four unique items.');
    }
    final answers = [...topic.items]..shuffle(_random);
    return answers
        .take(min(maximumQuestions, answers.length))
        .map((answer) {
          final distractors =
              topic.items.where((item) => item.id != answer.id).toList()
                ..shuffle(_random);
          final options = [answer, ...distractors.take(3)]..shuffle(_random);
          assert(options.map((item) => item.id).toSet().length == 4);
          assert(options.where((item) => item.id == answer.id).length == 1);
          return QuizQuestion(answer: answer, options: options);
        })
        .toList(growable: false);
  }
}
