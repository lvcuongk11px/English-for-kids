import 'package:material_ui/material_ui.dart';

import '../models/topic.dart';
import '../services/audio_service.dart';
import '../widgets/cloud_background.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.topic, required this.completed});
  final Topic topic;
  final int completed;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AppAudioService _audio = AudioService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _audio.playAsset('assets/audio/feedback/well_done.wav'),
    );
  }

  @override
  void dispose() {
    _audio.stop();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CloudBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 92)),
              const Text(
                'Well done!',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4B3DAE),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You finished ${widget.completed} questions!',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                child: FilledButton.icon(
                  key: const ValueKey('play-again'),
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizScreen(topic: widget.topic),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                child: OutlinedButton.icon(
                  key: const ValueKey('back-to-topics'),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Back to Topics'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
