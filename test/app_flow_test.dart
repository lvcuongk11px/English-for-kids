import 'dart:math';

import 'package:english_for_kids/main.dart';
import 'package:english_for_kids/models/topic.dart';
import 'package:english_for_kids/models/vocabulary_item.dart';
import 'package:english_for_kids/screens/quiz_screen.dart';
import 'package:english_for_kids/services/audio_service.dart';
import 'package:english_for_kids/services/quiz_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudio implements AppAudioService {
  final played = <String>[];
  @override
  Future<void> playAsset(String path) async => played.add(path);
  @override
  Future<void> playAssetAndWait(String path) async => played.add(path);
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

Topic testTopic() => Topic(
  id: 'animals',
  englishName: 'Animals',
  vietnameseName: 'Động vật',
  coverImagePath: 'assets/images/animals_cat.png',
  accentColor: 0xFFF06B5B,
  items: List.generate(
    4,
    (index) => VocabularyItem(
      id: 'animal$index',
      word: 'animal$index',
      questionText: 'Where is animal $index?',
      imagePath: 'assets/images/animals_cat.png',
      questionAudioPath: 'assets/audio/questions/animals_cat.wav',
    ),
  ),
);

void main() {
  testWidgets('Pinky home loads school lessons and starts an adventure', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const EnglishForKidsApp());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pump();
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 10),
      );
    } on FlutterError catch (error) {
      if (!error.message.contains('pumpAndSettle timed out')) {
        rethrow;
      }
    }
    expect(find.text('Hello, little explorer!'), findsOneWidget);
    expect(find.text('School Adventure'), findsOneWidget);
    expect(find.byKey(const ValueKey('big-play')), findsOneWidget);
    await tester.binding.setSurfaceSize(const Size(320, 568));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('big-play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('lesson-prompt')), findsOneWidget);
    expect(find.byKey(const ValueKey('explore-scene')), findsOneWidget);
  });
  testWidgets('wrong retry, correct advance, result, and back flow works', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final topic = testTopic();
    final audio = FakeAudio();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              key: const ValueKey('launch-quiz'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => QuizScreen(
                    topic: topic,
                    quizEngine: QuizEngine(random: Random(3)),
                    audioService: audio,
                  ),
                ),
              ),
              child: const Text('Test Home'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('launch-quiz')));
    await tester.pumpAndSettle();
    for (var round = 0; round < 4; round++) {
      final questionText = tester
          .widget<Text>(find.byKey(const ValueKey('question-text')))
          .data!;
      final answerIndex = int.parse(
        RegExp(r'(\d+)').firstMatch(questionText)!.group(1)!,
      );
      if (round == 0) {
        await tester.tap(
          find.byKey(ValueKey('answer-animal${(answerIndex + 1) % 4}')),
        );
        await tester.pump();
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      }
      await tester.tap(find.byKey(ValueKey('answer-animal$answerIndex')));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump();
    }
    expect(find.text('Well done!'), findsOneWidget);
    expect(find.byKey(const ValueKey('play-again')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('back-to-topics')));
    await tester.pumpAndSettle();
    expect(find.text('Test Home'), findsOneWidget);
  });
}
