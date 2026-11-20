import 'dart:math';

import '../models/catalog_models.dart';
import '../models/game_activity.dart';
import 'game_registry.dart';

class LessonEngine {
  LessonEngine({Random? random, this.registry = const GameRegistry()})
    : _random = random ?? Random();
  final Random _random;
  final GameRegistry registry;

  List<GameActivity> build(
    LessonDefinition lesson,
    List<VocabularyEntry> vocabulary, {
    int maximumActivities = 7,
    int prioritizedVocabularyCount = 0,
  }) {
    if (vocabulary.length < 4) {
      throw ArgumentError(
        'A playable lesson requires four clear vocabulary items.',
      );
    }
    final priorityCount = prioritizedVocabularyCount.clamp(
      0,
      vocabulary.length,
    );
    final prioritized = vocabulary.take(priorityCount).toList()
      ..shuffle(_random);
    final remaining = vocabulary.skip(priorityCount).toList()..shuffle(_random);
    final pool = [...prioritized, ...remaining];
    final games = registry.gamesFor(lesson);
    final activities = <GameActivity>[];
    for (var index = 0; index < maximumActivities; index++) {
      final type = games[index % games.length];
      final count = type == GameType.counting ? 1 + _random.nextInt(5) : null;
      final target = type == GameType.counting
          ? pool.firstWhere(
              (item) => item.id == '$count',
              orElse: () => pool[index % pool.length],
            )
          : pool[index % pool.length];
      final distractors = pool.where((item) => item.id != target.id).toList()
        ..shuffle(_random);
      final optionCount = type == GameType.matchingPairs
          ? min(3, pool.length)
          : min(4, pool.length);
      final options = type == GameType.explore || type == GameType.matchingPairs
          ? pool.take(optionCount).toList()
          : ([target, ...distractors.take(optionCount - 1)]..shuffle(_random));
      activities.add(
        GameActivity(
          type: type,
          target: target,
          options: options,
          count: count,
        ),
      );
    }
    for (var i = 1; i < activities.length; i++) {
      assert(activities[i].type != activities[i - 1].type || games.length == 1);
    }
    return activities;
  }
}
