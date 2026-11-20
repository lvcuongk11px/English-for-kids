import 'catalog_models.dart';

enum GameType {
  explore,
  dragDrop,
  hiddenObjects,
  coloring,
  matchingPairs,
  counting,
}

class GameActivity {
  const GameActivity({
    required this.type,
    required this.target,
    required this.options,
    this.count,
  });
  final GameType type;
  final VocabularyEntry target;
  final List<VocabularyEntry> options;
  final int? count;
}
