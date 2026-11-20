import 'package:material_ui/material_ui.dart';

import '../models/catalog_models.dart';
import '../models/learning_level.dart';
import '../models/learning_settings.dart';
import '../services/catalog_repository.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../widgets/cloud_background.dart';
import '../widgets/pinky_mascot.dart';
import 'lesson_screen.dart';
import 'sticker_album_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.repository = const CatalogRepository(),
    this.progress = const ProgressService(),
    this.settingsService = const SettingsService(),
  });
  final CatalogRepository repository;
  final ProgressService progress;
  final SettingsService settingsService;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeData {
  const _HomeData(this.catalog, this.settings, this.completed, this.stickers);
  final CatalogBundle catalog;
  final LearningSettings settings;
  final Set<String> completed;
  final Set<String> stickers;
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _data = _load();
  Future<_HomeData> _load() async {
    final catalog = await widget.repository.load();
    final settings = await widget.settingsService.load();
    final completed = await widget.progress.completedLessons();
    final stickers = await widget.progress.loadStickers();
    return _HomeData(catalog, settings, completed, stickers);
  }

  void _refresh() => setState(() => _data = _load());
  Future<void> _openLesson(_HomeData data, LessonDefinition lesson) async {
    final words = [...data.catalog.playableFor(lesson)];
    var reviewWordCount = 0;
    if (data.settings.reviewModeEnabled) {
      final history = await widget.progress.loadWordProgress();
      words.sort((a, b) {
        final aReview = history[a.id]?.needsReview ?? false;
        final bReview = history[b.id]?.needsReview ?? false;
        if (aReview == bReview) return 0;
        return aReview ? -1 : 1;
      });
      reviewWordCount = words
          .where((word) => history[word.id]?.needsReview ?? false)
          .length;
    }
    if (!mounted) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LessonScreen(
              lesson: lesson,
              vocabulary: words,
              settings: data.settings,
              prioritizedVocabularyCount: reviewWordCount,
            ),
          ),
        )
        .then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CloudBackground(
      child: FutureBuilder<_HomeData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Pinky needs a little help!\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final school = data.catalog.lessons
              .where((lesson) => lesson.sourceType == 'school_verified')
              .toList();
          final extra = data.catalog.lessons
              .where((lesson) => lesson.sourceType == 'extra_class_inferred')
              .toList();
          final next = school.firstWhere(
            (lesson) => !data.completed.contains(lesson.id),
            orElse: () => school.first,
          );
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  data: data,
                  next: next,
                  onPlay: () => _openLesson(data, next),
                  onAlbum: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StickerAlbumScreen(
                        stickerIds: data.stickers,
                        vocabulary: data.catalog.vocabulary,
                      ),
                    ),
                  ),
                  onTopics: () => _showTopics(data),
                  onSettings: () => _showParentSettings(data.settings),
                ),
              ),
              const SliverToBoxAdapter(
                child: _SectionTitle('School Adventure'),
              ),
              _lessonGrid(school, data),
              const SliverToBoxAdapter(
                child: _SectionTitle('Extra-Class Worlds'),
              ),
              _lessonGrid(extra, data, bottom: 28),
            ],
          );
        },
      ),
    ),
  );

  Widget _lessonGrid(
    List<LessonDefinition> lessons,
    _HomeData data, {
    double bottom = 0,
  }) => SliverPadding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
    sliver: SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .88,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _LessonCard(
          lesson: lesson,
          completed: data.completed.contains(lesson.id),
          words: data.catalog.playableFor(lesson),
          onTap: () => _openLesson(data, lesson),
        );
      },
    ),
  );

  Future<void> _showParentSettings(LearningSettings current) async {
    var value = current;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parents Settings',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Language level',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SegmentedButton<LearningLevel>(
                  segments: [
                    for (final level in LearningLevel.values)
                      ButtonSegment(
                        value: level,
                        label: Text('${level.value}'),
                        tooltip: level.label,
                      ),
                  ],
                  selected: {value.level},
                  onSelectionChanged: (selection) => setSheet(
                    () => value = value.copyWith(level: selection.first),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Speech speed: ${value.speechRate.toStringAsFixed(2)}Ã—',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Slider(
                  value: value.speechRate,
                  min: .72,
                  max: .95,
                  divisions: 23,
                  label: value.speechRate.toStringAsFixed(2),
                  onChanged: (speed) =>
                      setSheet(() => value = value.copyWith(speechRate: speed)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto Next'),
                  subtitle: const Text('Waits 2.7 seconds after speech'),
                  value: value.autoAdvanceEnabled,
                  onChanged: (enabled) => setSheet(
                    () => value = value.copyWith(autoAdvanceEnabled: enabled),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sound effects'),
                  value: value.soundEffectsEnabled,
                  onChanged: (enabled) => setSheet(
                    () => value = value.copyWith(soundEffectsEnabled: enabled),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Review Mode'),
                  value: value.reviewModeEnabled,
                  onChanged: (enabled) => setSheet(
                    () => value = value.copyWith(reviewModeEnabled: enabled),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    await widget.settingsService.save(value);
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                    _refresh();
                  },
                  child: const Text('Save Settings'),
                ),
                TextButton(
                  onPressed: () async {
                    final yes = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset progress?'),
                        content: const Text(
                          'Stars, stickers and review history will be removed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (yes == true) {
                      await widget.progress.reset();
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                      _refresh();
                    }
                  },
                  child: const Text(
                    'Reset Progress',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTopics(_HomeData data) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: .8,
        maxChildSize: .94,
        builder: (context, controller) => ListView.builder(
          controller: controller,
          padding: const EdgeInsets.all(16),
          itemCount: data.catalog.lessons.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Choose a Topic',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                ),
              );
            }
            final lesson = data.catalog.lessons[index - 1];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFD4E0),
                child: Text('${lesson.week ?? '★'}'),
              ),
              title: Text(
                lesson.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${lesson.schoolLevel} • ${data.catalog.playableFor(lesson).length} words',
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _openLesson(data, lesson);
              },
            );
          },
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.data,
    required this.next,
    required this.onPlay,
    required this.onAlbum,
    required this.onTopics,
    required this.onSettings,
  });
  final _HomeData data;
  final LessonDefinition next;
  final VoidCallback onPlay;
  final VoidCallback onAlbum;
  final VoidCallback onTopics;
  final VoidCallback onSettings;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PinkyMascot(mood: PinkyMood.hello, size: 112),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, little explorer!',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Learn with Pinky!',
                      style: TextStyle(
                        color: Color(0xFF65758B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Parents: press and hold.')),
              ),
              onLongPress: onSettings,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.settings_rounded,
                  size: 31,
                  color: Color(0xFF6657D9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const ValueKey('big-play'),
          onPressed: onPlay,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7FA3),
            minimumSize: const Size.fromHeight(62),
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 34),
          label: Text(
            'Play • ${next.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAlbum,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text('Stickers ${data.stickers.length}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTopics,
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('All Topics'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
    ),
  );
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.completed,
    required this.words,
    required this.onTap,
  });
  final LessonDefinition lesson;
  final bool completed;
  final List<VocabularyEntry> words;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cover = words.first;
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('lesson-${lesson.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEF4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(cover.imagePath!),
                        ),
                      ),
                    ),
                    if (completed)
                      const Positioned(
                        right: 4,
                        top: 4,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Color(0xFFFFC83D),
                          child: Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                lesson.vietnameseTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF65758B)),
              ),
              Text(
                '${words.length} words',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6657D9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
