import 'vocabulary_item.dart';

class QuizQuestion {
  const QuizQuestion({required this.answer, required this.options});
  final VocabularyItem answer;
  final List<VocabularyItem> options;
}
