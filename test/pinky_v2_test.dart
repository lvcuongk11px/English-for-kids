import 'dart:async';
import 'dart:convert';

import 'package:english_for_kids/models/catalog_models.dart';
import 'package:english_for_kids/models/game_activity.dart';
import 'package:english_for_kids/models/learning_settings.dart';
import 'package:english_for_kids/screens/lesson_screen.dart';
import 'package:english_for_kids/services/audio_service.dart';
import 'package:english_for_kids/services/game_registry.dart';
import 'package:english_for_kids/services/lesson_engine.dart';
import 'package:english_for_kids/services/progress_service.dart';
import 'package:english_for_kids/widgets/game_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

VocabularyEntry word(String id, {String? english}) => VocabularyEntry(
  id: id,
  english: english ?? id,
  vietnamese: id,
  aliases: [id],
  topicIds: const ['test'],
  sourceTypes: const ['school_verified'],
  difficulty: 'easy',
  imagePath: 'assets/images/animals_cat.png',
  audioPath: 'assets/audio/words/cat.wav',
);
LessonDefinition lesson(String id) => LessonDefinition(
  id: id,
  title: 'Test',
  vietnameseTitle: 'Thử',
  worldId: 'test',
  sourceType: 'school_verified',
  week: 1,
  schoolLevel: 'Pre-Starters 1',
  vocabularyIds: const ['cat', 'dog', 'pig', 'cow'],
  sentencePatterns: const ['What animal is it?'],
  gameTypes: const [],
);
Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: SafeArea(
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    ),
  ),
);

class FixedEngine extends LessonEngine {
  FixedEngine(this.activities);
  final List<GameActivity> activities;
  @override
  List<GameActivity> build(
    LessonDefinition lesson,
    List<VocabularyEntry> vocabulary, {
    int maximumActivities = 7,
    int prioritizedVocabularyCount = 0,
  }) => activities;
}

class ControlledAudio implements AppAudioService {
  final waits = <Completer<void>>[];
  final played = <String>[];
  int active = 0;
  int maxActive = 0;
  @override
  Future<void> playAsset(String path) async {
    played.add(path);
  }

  @override
  Future<void> playAssetAndWait(String path) {
    played.add(path);
    final completer = Completer<void>();
    waits.add(completer);
    active++;
    maxActive = active > maxActive ? active : maxActive;
    return completer.future.whenComplete(() => active--);
  }

  @override
  Future<void> stop() async {
    for (final wait in waits.where((item) => !item.isCompleted)) {
      wait.complete();
    }
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final items = [word('cat'), word('dog'), word('pig'), word('cow')];

  test('source catalogs preserve verified and inferred provenance', () async {
    final vocabulary = jsonDecode(
      await rootBundle.loadString('assets/data/vocabulary_catalog.json'),
    ) as Map<String, dynamic>;
    final lessons = jsonDecode(
      await rootBundle.loadString('assets/data/lesson_catalog.json'),
    ) as Map<String, dynamic>;
    final entries = vocabulary['items'] as List<dynamic>;
    final allLessons = lessons['lessons'] as List<dynamic>;
    expect(
      entries.map((raw) => (raw as Map<String, dynamic>)['id']).toSet().length,
      entries.length,
    );
    expect(
      entries
          .where(
            (raw) => (raw as Map<String, dynamic>)['sourceTypes'].contains(
              'school_verified',
            ),
          )
          .length,
      134,
    );
    expect(
      entries
          .where(
            (raw) => (raw as Map<String, dynamic>)['sourceTypes'].contains(
              'extra_class_inferred',
            ),
          )
          .length,
      128,
    );
    final inferred = allLessons.where(
      (raw) =>
          (raw as Map<String, dynamic>)['sourceType'] == 'extra_class_inferred',
    );
    expect(inferred, hasLength(9));
    for (final raw in inferred) {
      expect(
        (raw as Map<String, dynamic>)['candidateTerms'],
        hasLength(greaterThanOrEqualTo(15)),
      );
    }
  });

  test('registry and engine produce varied activities with unique options', () {
    final shapes = lesson('school_shapes');
    final types = const GameRegistry().gamesFor(shapes);
    expect(
      types,
      containsAll([
        GameType.explore,
        GameType.dragDrop,
        GameType.hiddenObjects,
        GameType.coloring,
        GameType.matchingPairs,
      ]),
    );
    final activities = LessonEngine().build(
      shapes,
      items,
      maximumActivities: 7,
    );
    expect(activities, hasLength(7));
    for (final activity in activities) {
      expect(
        activity.options.map((item) => item.id).toSet().length,
        activity.options.length,
      );
    }
    for (var i = 1; i < activities.length; i++) {
      expect(activities[i].type, isNot(activities[i - 1].type));
    }
  });

  test('review vocabulary is scheduled before ordinary vocabulary', () {
    final activities = LessonEngine().build(
      lesson('school_animals'),
      items,
      maximumActivities: 2,
      prioritizedVocabularyCount: 2,
    );
    expect(
      activities.map((activity) => activity.target.id).toSet(),
      equals({'cat', 'dog'}),
    );
  });

  testWidgets('Explore Scene hotspots speak and unlock Next', (tester) async {
    final heard = <String>[];
    var completed = false;
    final activity = GameActivity(
      type: GameType.explore,
      target: items.first,
      options: items,
    );
    await tester.pumpWidget(
      host(
        ExploreSceneGame(
          activity: activity,
          onHeard: (item) => heard.add(item.id),
          onComplete: () => completed = true,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('explore-cat')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('explore-dog')));
    await tester.pump();
    expect(heard, ['cat', 'dog']);
    await tester.tap(find.textContaining('Next'));
    expect(completed, isTrue);
  });

  testWidgets('Drag Drop supports real drag and tap alternative', (
    tester,
  ) async {
    final answers = <bool>[];
    final activity = GameActivity(
      type: GameType.dragDrop,
      target: items.first,
      options: items,
    );
    await tester.pumpWidget(
      host(
        DragDropGame(
          key: UniqueKey(),
          activity: activity,
          onAnswer: (item, correct) => answers.add(correct),
        ),
      ),
    );
    final source = find.byKey(const ValueKey('drag-cat'));
    final target = find.byKey(const ValueKey('drop-zone'));
    await tester.drag(
      source,
      tester.getCenter(target) - tester.getCenter(source),
    );
    await tester.pump();
    expect(answers, contains(true));
    answers.clear();
    await tester.pumpWidget(
      host(
        DragDropGame(
          activity: activity,
          onAnswer: (item, correct) => answers.add(correct),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('select-cat')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('drop-tap-zone')));
    await tester.pump();
    expect(answers, contains(true));
  });

  testWidgets('Hidden Objects selects the scene object', (tester) async {
    final answers = <bool>[];
    final activity = GameActivity(
      type: GameType.hiddenObjects,
      target: items[1],
      options: items,
    );
    await tester.pumpWidget(
      host(
        HiddenObjectsGame(
          activity: activity,
          onAnswer: (item, correct) => answers.add(correct),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('hidden-dog')));
    await tester.pump();
    expect(answers, [true]);
  });

  testWidgets('Coloring changes the picture color', (tester) async {
    var complete = false;
    final red = word('red', english: 'red');
    final activity = GameActivity(
      type: GameType.coloring,
      target: red,
      options: [red, ...items.take(3)],
    );
    await tester.pumpWidget(
      host(ColoringGame(activity: activity, onComplete: () => complete = true)),
    );
    const redValue = 0xFFE84141;
    await tester.tap(find.byKey(const ValueKey('paint-$redValue')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('coloring-target')));
    await tester.pump();
    expect(complete, isTrue);
  });

  testWidgets('Matching Pairs completes identical pairs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var complete = false;
    final activity = GameActivity(
      type: GameType.matchingPairs,
      target: items.first,
      options: items.take(2).toList(),
    );
    await tester.pumpWidget(
      host(
        MatchingPairsGame(
          activity: activity,
          onMatched: (_) {},
          onComplete: () => complete = true,
        ),
      ),
    );
    for (final item in activity.options) {
      final pair = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('match-') &&
            (widget.key! as ValueKey<String>).value.endsWith('-${item.id}'),
      );
      expect(pair, findsNWidgets(2));
      await tester.tap(pair.at(0));
      await tester.tap(pair.at(1));
      await tester.pump();
    }
    expect(complete, isTrue);
  });

  testWidgets('Counting requires tapping objects and the right number', (
    tester,
  ) async {
    final answers = <bool>[];
    final three = word('3', english: 'three');
    final activity = GameActivity(
      type: GameType.counting,
      target: three,
      options: [three, ...items.take(3)],
      count: 3,
    );
    await tester.pumpWidget(
      host(
        CountingGame(
          activity: activity,
          onAnswer: (item, correct) => answers.add(correct),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(ValueKey('count-object-$i')));
    }
    await tester.tap(find.byKey(const ValueKey('number-3')));
    expect(answers, [true]);
  });

  testWidgets('lesson waits for audio completion and slow success delay', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final audio = ControlledAudio();
    final first = GameActivity(
      type: GameType.hiddenObjects,
      target: items.first,
      options: items,
    );
    final second = GameActivity(
      type: GameType.explore,
      target: items[1],
      options: items,
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: LessonScreen(
          lesson: lesson('school_animals'),
          vocabulary: items,
          settings: const LearningSettings(),
          engine: FixedEngine([first, second]),
          audio: audio,
          progress: const ProgressService(),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('hidden-cat')));
    await tester.pump();
    expect(audio.waits, hasLength(1));
    audio.waits[0].complete();
    await tester.pump();
    expect(audio.waits, hasLength(2));
    audio.waits[1].complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2600));
    expect(
      find.byKey(const ValueKey('activity-0-hiddenObjects')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('activity-1-explore')), findsOneWidget);
    expect(audio.maxActive, 1);
  });

  test('progress and stickers persist locally', () async {
    SharedPreferences.setMockInitialValues({});
    const service = ProgressService();
    await service.recordAnswer('cat', false);
    await service.recordAnswer('cat', true);
    await service.awardSticker('cat');
    await service.completeLesson('animals');
    final progress = await service.loadWordProgress();
    expect(progress['cat']!.seen, 2);
    expect(progress['cat']!.wrong, 1);
    expect(await service.loadStickers(), contains('cat'));
    expect(await service.completedLessons(), contains('animals'));
  });
}
