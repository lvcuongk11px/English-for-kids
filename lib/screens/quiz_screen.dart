import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../models/quiz_question.dart';
import '../models/topic.dart';
import '../services/audio_service.dart';
import '../services/quiz_engine.dart';
import '../widgets/cloud_background.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  QuizScreen({
    super.key,
    required this.topic,
    QuizEngine? quizEngine,
    AppAudioService? audioService,
  }) : quizEngine = quizEngine ?? QuizEngine(),
       audioService = audioService ?? AudioService();
  final Topic topic;
  final QuizEngine quizEngine;
  final AppAudioService audioService;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions;
  int _index = 0;
  String? _wrongId;
  String? _correctId;
  bool _locked = false;
  Timer? _nextTimer;
  QuizQuestion get _question => _questions[_index];

  @override
  void initState() {
    super.initState();
    _questions = widget.quizEngine.createSession(widget.topic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _playQuestion());
  }

  Future<void> _playQuestion() =>
      widget.audioService.playAsset(_question.answer.questionAudioPath);
  Future<void> _choose(String id) async {
    if (_locked) return;
    if (id != _question.answer.id) {
      setState(() => _wrongId = id);
      await widget.audioService.playAsset(
        'assets/audio/feedback/try_again.wav',
      );
      return;
    }
    setState(() {
      _locked = true;
      _wrongId = null;
      _correctId = id;
    });
    await widget.audioService.playAsset('assets/audio/effects/correct.wav');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    await widget.audioService.playAsset('assets/audio/feedback/great_job.wav');
    if (mounted) {
      _nextTimer = Timer(const Duration(milliseconds: 900), _advance);
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_index == _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ResultScreen(topic: widget.topic, completed: _questions.length),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _wrongId = null;
      _correctId = null;
      _locked = false;
    });
    _playQuestion();
  }

  @override
  void dispose() {
    _nextTimer?.cancel();
    widget.audioService.stop();
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / _questions.length;
    return Scaffold(
      body: CloudBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Back to topics',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        key: const ValueKey('quiz-progress'),
                        value: progress,
                        minHeight: 13,
                        backgroundColor: Colors.white,
                        color: const Color(0xFF5AC77A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_index + 1}/${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _question.answer.questionText,
                        key: const ValueKey('question-text'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      key: const ValueKey('replay-audio'),
                      tooltip: 'Listen again',
                      onPressed: _playQuestion,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF6657D9),
                      ),
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final option = _question.options[index];
                    final isWrong = option.id == _wrongId;
                    final isCorrect = option.id == _correctId;
                    final color = isCorrect
                        ? const Color(0xFF42C76A)
                        : isWrong
                        ? const Color(0xFFFF5E67)
                        : Colors.white;
                    return Semantics(
                      button: true,
                      label: 'Answer ${index + 1}',
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: ValueKey('answer-${option.id}'),
                          onTap: () => _choose(option.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: color,
                                width: isWrong || isCorrect ? 6 : 3,
                              ),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    option.imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                if (isWrong || isCorrect)
                                  Positioned(
                                    right: 7,
                                    top: 7,
                                    child: CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(
                                        isCorrect
                                            ? Icons.check_rounded
                                            : Icons.close_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
