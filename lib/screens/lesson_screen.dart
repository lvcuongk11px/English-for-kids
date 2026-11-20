import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/catalog_models.dart';
import '../models/game_activity.dart';
import '../models/learning_settings.dart';
import '../services/audio_service.dart';
import '../services/lesson_engine.dart';
import '../services/progress_service.dart';
import '../widgets/cloud_background.dart';
import '../widgets/game_widgets.dart';
import '../widgets/pinky_mascot.dart';
import 'adventure_result_screen.dart';

class LessonScreen extends StatefulWidget {
  LessonScreen({
    super.key,
    required this.lesson,
    required this.vocabulary,
    required this.settings,
    this.prioritizedVocabularyCount = 0,
    LessonEngine? engine,
    AppAudioService? audio,
    ProgressService? progress,
  }) : engine = engine ?? LessonEngine(),
       audio = audio ?? AudioService(playbackRate: settings.speechRate / 0.82),
       progress = progress ?? const ProgressService();
  final LessonDefinition lesson;
  final List<VocabularyEntry> vocabulary;
  final LearningSettings settings;
  final int prioritizedVocabularyCount;
  final LessonEngine engine;
  final AppAudioService audio;
  final ProgressService progress;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<GameActivity> _activities;
  int _index = 0;
  bool _locked = false;
  bool _showNext = false;
  PinkyMood _mood = PinkyMood.listening;
  Timer? _timer;
  GameActivity get _activity => _activities[_index];
  @override
  void initState() {
    super.initState();
    _activities = widget.engine.build(
      widget.lesson,
      widget.vocabulary,
      prioritizedVocabularyCount: widget.prioritizedVocabularyCount,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakTarget());
  }

  Future<void> _speakTarget() =>
      widget.audio.playAsset(_activity.target.audioPath);
  String get _prompt {
    final word = _activity.target.english;
    switch (widget.settings.level.value) {
      case 1:
        return '${word[0].toUpperCase()}${word.substring(1)}!';
      case 2:
        return 'Find ${word.contains(' ') ? '' : 'the '}$word!';
      default:
        return widget.lesson.sentencePatterns.isEmpty
            ? 'What is it?'
            : widget.lesson.sentencePatterns.first;
    }
  }

  Future<void> _answer(VocabularyEntry item, bool correct) async {
    if (_locked) return;
    await widget.progress.recordAnswer(
      correct ? item.id : _activity.target.id,
      correct,
    );
    if (!correct) {
      setState(() {
        _mood = PinkyMood.encourage;
      });
      await widget.audio.playAssetAndWait(
        'assets/audio/feedback/try_again.wav',
      );
      if (mounted) setState(() => _mood = PinkyMood.listening);
      return;
    }
    setState(() {
      _locked = true;
      _mood = PinkyMood.happy;
      _showNext = true;
    });
    if (widget.settings.soundEffectsEnabled) {
      await widget.audio.playAssetAndWait('assets/audio/effects/correct.wav');
    }
    await widget.audio.playAssetAndWait(item.audioPath);
    if (!mounted) return;
    if (widget.settings.autoAdvanceEnabled) {
      _timer = Timer(widget.settings.successDelay, _advance);
    }
  }

  void _heard(VocabularyEntry item) {
    widget.progress.recordAnswer(item.id, true);
    widget.audio.playAsset(item.audioPath);
    setState(() => _mood = PinkyMood.happy);
  }

  void _gentleComplete() {
    if (_locked) return;
    setState(() {
      _locked = true;
      _showNext = true;
      _mood = PinkyMood.happy;
    });
    if (widget.settings.autoAdvanceEnabled) {
      _timer = Timer(widget.settings.successDelay, _advance);
    }
  }

  void _completeTarget() {
    widget.progress.recordAnswer(_activity.target.id, true);
    _gentleComplete();
  }

  void _advance() {
    _timer?.cancel();
    if (!mounted) return;
    if (_index == _activities.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AdventureResultScreen(
            lesson: widget.lesson,
            completed: _activities.length,
            sticker: _activity.target,
            progress: widget.progress,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _locked = false;
      _showNext = false;
      _mood = PinkyMood.listening;
    });
    _speakTarget();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.audio.stop();
    widget.audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CloudBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Leave lesson',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: (_index + 1) / _activities.length,
                      minHeight: 13,
                      backgroundColor: Colors.white,
                      color: const Color(0xFFFF8FB1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_index + 1}/${_activities.length}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(
              height: 80,
              child: Row(
                children: [
                  PinkyMascot(mood: _mood, size: 78),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _prompt,
                        key: const ValueKey('lesson-prompt'),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    key: const ValueKey('replay-word'),
                    onPressed: _speakTarget,
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AbsorbPointer(
                absorbing: _locked,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey('activity-$_index-${_activity.type.name}'),
                    child: _game(),
                  ),
                ),
              ),
            ),
            if (_showNext)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  key: const ValueKey('next-activity'),
                  onPressed: _advance,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  Widget _game() {
    switch (_activity.type) {
      case GameType.explore:
        return ExploreSceneGame(
          activity: _activity,
          onHeard: _heard,
          onComplete: _gentleComplete,
        );
      case GameType.dragDrop:
        return DragDropGame(activity: _activity, onAnswer: _answer);
      case GameType.hiddenObjects:
        return HiddenObjectsGame(activity: _activity, onAnswer: _answer);
      case GameType.coloring:
        return ColoringGame(activity: _activity, onComplete: _completeTarget);
      case GameType.matchingPairs:
        return MatchingPairsGame(
          activity: _activity,
          onMatched: _heard,
          onComplete: _gentleComplete,
        );
      case GameType.counting:
        return CountingGame(activity: _activity, onAnswer: _answer);
    }
  }
}
