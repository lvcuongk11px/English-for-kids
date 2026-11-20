import 'package:material_ui/material_ui.dart';

import '../models/catalog_models.dart';
import '../services/progress_service.dart';
import '../widgets/cloud_background.dart';
import '../widgets/pinky_mascot.dart';

class AdventureResultScreen extends StatefulWidget {
  const AdventureResultScreen({
    super.key,
    required this.lesson,
    required this.completed,
    required this.sticker,
    required this.progress,
  });
  final LessonDefinition lesson;
  final int completed;
  final VocabularyEntry sticker;
  final ProgressService progress;
  @override
  State<AdventureResultScreen> createState() => _AdventureResultScreenState();
}

class _AdventureResultScreenState extends State<AdventureResultScreen> {
  @override
  void initState() {
    super.initState();
    widget.progress.completeLesson(widget.lesson.id);
    widget.progress.awardSticker(widget.sticker.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CloudBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const PinkyMascot(mood: PinkyMood.celebrate, size: 180),
              const Text(
                'Yay! Well done!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6B4EB0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You finished ${widget.completed} adventures!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 170,
                height: 170,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1B8),
                  border: Border.all(color: const Color(0xFFFFC83D), width: 5),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    Expanded(child: Image.asset(widget.sticker.imagePath!)),
                    Text(
                      '${widget.sticker.english} sticker!',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 270,
                child: FilledButton.icon(
                  key: const ValueKey('play-again-v2'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Choose Another Lesson'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 270,
                child: OutlinedButton.icon(
                  key: const ValueKey('back-home-v2'),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
