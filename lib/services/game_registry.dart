import '../models/catalog_models.dart';
import '../models/game_activity.dart';

class GameRegistry {
  const GameRegistry();
  List<GameType> gamesFor(LessonDefinition lesson) {
    final allowed = <GameType>{
      GameType.explore,
      GameType.dragDrop,
      GameType.hiddenObjects,
      GameType.matchingPairs,
    };
    if (lesson.id.contains('shape') || lesson.id.contains('autumn')) {
      allowed.add(GameType.coloring);
    }
    if (lesson.id.contains('number')) allowed.add(GameType.counting);
    return allowed.toList(growable: false);
  }
}
