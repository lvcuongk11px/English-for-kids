import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/game_activity.dart';
import '../models/catalog_models.dart';

typedef GameAnswer = void Function(VocabularyEntry item, bool correct);

class ExploreSceneGame extends StatefulWidget {
  const ExploreSceneGame({
    super.key,
    required this.activity,
    required this.onHeard,
    required this.onComplete,
  });
  final GameActivity activity;
  final ValueChanged<VocabularyEntry> onHeard;
  final VoidCallback onComplete;
  @override
  State<ExploreSceneGame> createState() => _ExploreSceneGameState();
}

class _ExploreSceneGameState extends State<ExploreSceneGame> {
  final _heard = <String>{};
  String? _active;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        'Explore with Pinky!',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      ),
      const Text(
        'Tap every picture',
        style: TextStyle(color: Color(0xFF65758B)),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: LayoutBuilder(
          builder: (context, size) => Container(
            key: const ValueKey('explore-scene'),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCDEEFF), Color(0xFFE8F5C8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 12,
                  left: 18,
                  child: Icon(
                    Icons.cloud_rounded,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                for (var i = 0; i < widget.activity.options.length; i++)
                  Positioned(
                    left: (i % 2) * (size.maxWidth / 2) + 18,
                    top: 65 + (i ~/ 2) * (size.maxHeight / 2.7),
                    width: size.maxWidth / 2 - 36,
                    height: size.maxHeight / 3.2,
                    child: Semantics(
                      button: true,
                      label: widget.activity.options[i].english,
                      child: GestureDetector(
                        key: ValueKey(
                          'explore-${widget.activity.options[i].id}',
                        ),
                        onTap: () {
                          final item = widget.activity.options[i];
                          setState(() {
                            _heard.add(item.id);
                            _active = item.id;
                          });
                          widget.onHeard(item);
                        },
                        child: AnimatedScale(
                          scale: _active == widget.activity.options[i].id
                              ? 1.12
                              : 1,
                          duration: const Duration(milliseconds: 220),
                          child: Image.asset(
                            widget.activity.options[i].imagePath!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: _heard.length >= math.min(2, widget.activity.options.length)
            ? widget.onComplete
            : null,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text('Next  ${_heard.length}/${widget.activity.options.length}'),
      ),
    ],
  );
}

class DragDropGame extends StatefulWidget {
  const DragDropGame({
    super.key,
    required this.activity,
    required this.onAnswer,
  });
  final GameActivity activity;
  final GameAnswer onAnswer;
  @override
  State<DragDropGame> createState() => _DragDropGameState();
}

class _DragDropGameState extends State<DragDropGame> {
  String? _selected;
  bool _placed = false;
  void _check(String id) {
    final item = widget.activity.options.firstWhere((entry) => entry.id == id);
    final correct = id == widget.activity.target.id;
    widget.onAnswer(item, correct);
    if (correct) setState(() => _placed = true);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '${widget.activity.target.english[0].toUpperCase()}${widget.activity.target.english.substring(1)}!',
        key: const ValueKey('game-prompt'),
        style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
      ),
      const Text(
        'Drag it into Pinky’s basket — or tap both',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      Expanded(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final item in widget.activity.options)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Draggable<String>(
                    data: item.id,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 105,
                        height: 105,
                        child: Image.asset(item.imagePath!),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: .25,
                      child: _option(item),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey('drag-${item.id}'),
                      child: _option(item),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: TextButton(
                      key: ValueKey('select-${item.id}'),
                      onPressed: () => setState(() => _selected = item.id),
                      child: Text(_selected == item.id ? 'Selected ✓' : 'Tap'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      DragTarget<String>(
        key: const ValueKey('drop-zone'),
        onWillAcceptWithDetails: (_) => !_placed,
        onAcceptWithDetails: (details) => _check(details.data),
        builder: (context, candidates, rejected) => GestureDetector(
          key: const ValueKey('drop-tap-zone'),
          onTap: _selected == null ? null : () => _check(_selected!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 210,
            height: 110,
            decoration: BoxDecoration(
              color: _placed
                  ? const Color(0xFFD8F7DF)
                  : candidates.isNotEmpty
                  ? const Color(0xFFFFE7A5)
                  : const Color(0xFFFFF2D2),
              border: Border.all(
                color: _placed
                    ? const Color(0xFF4DBB78)
                    : const Color(0xFFD79A39),
                width: 4,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(34),
                top: Radius.circular(10),
              ),
            ),
            child: Center(
              child: _placed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 62,
                      color: Color(0xFF32A85B),
                    )
                  : const Text(
                      'BASKET',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF8B6123),
                      ),
                    ),
            ),
          ),
        ),
      ),
    ],
  );
  Widget _option(VocabularyEntry item) => AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: 122,
    height: 122,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: _selected == item.id ? const Color(0xFF6657D9) : Colors.white,
        width: 4,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Image.asset(item.imagePath!),
  );
}

class HiddenObjectsGame extends StatefulWidget {
  const HiddenObjectsGame({
    super.key,
    required this.activity,
    required this.onAnswer,
  });
  final GameActivity activity;
  final GameAnswer onAnswer;
  @override
  State<HiddenObjectsGame> createState() => _HiddenObjectsGameState();
}

class _HiddenObjectsGameState extends State<HiddenObjectsGame> {
  String? _found;
  String? _wrong;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        'Find ${widget.activity.target.english}!',
        key: const ValueKey('game-prompt'),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
      const Text('Look around Pinky’s room'),
      const SizedBox(height: 8),
      Expanded(
        child: LayoutBuilder(
          builder: (context, size) => Container(
            key: const ValueKey('hidden-scene'),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDE7),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: size.maxHeight * .3,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1B995),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 20,
                  top: 16,
                  child: Icon(
                    Icons.window_rounded,
                    size: 90,
                    color: Color(0xFF94D7ED),
                  ),
                ),
                for (var i = 0; i < widget.activity.options.length; i++)
                  Positioned(
                    left: 14 + (i % 2) * (size.maxWidth / 2),
                    top: 70 + (i ~/ 2) * (size.maxHeight / 2.8),
                    width: size.maxWidth / 2 - 30,
                    height: size.maxHeight / 3.3,
                    child: GestureDetector(
                      key: ValueKey('hidden-${widget.activity.options[i].id}'),
                      onTap: () {
                        final item = widget.activity.options[i];
                        final correct = item.id == widget.activity.target.id;
                        setState(() {
                          if (correct) {
                            _found = item.id;
                          } else {
                            _wrong = item.id;
                          }
                        });
                        widget.onAnswer(item, correct);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        decoration: BoxDecoration(
                          color: _found == widget.activity.options[i].id
                              ? const Color(0x665AC77A)
                              : _wrong == widget.activity.options[i].id
                              ? const Color(0x44FF5E67)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          widget.activity.options[i].imagePath!,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class ColoringGame extends StatefulWidget {
  const ColoringGame({
    super.key,
    required this.activity,
    required this.onComplete,
  });
  final GameActivity activity;
  final VoidCallback onComplete;
  @override
  State<ColoringGame> createState() => _ColoringGameState();
}

class _ColoringGameState extends State<ColoringGame> {
  static const palette = <String, Color>{
    'red': Color(0xFFE84141),
    'yellow': Color(0xFFF3CE35),
    'blue': Color(0xFF3987E8),
    'green': Color(0xFF43B96B),
    'pink': Color(0xFFF17FA5),
  };
  Color? _selected;
  Color? _painted;
  Color get _target =>
      palette[widget.activity.target.english] ?? palette['red']!;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '${palette.containsKey(widget.activity.target.english) ? widget.activity.target.english : 'Red'}!',
        key: const ValueKey('game-prompt'),
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
      ),
      const Text('Pick a color, then tap the star'),
      Expanded(
        child: GestureDetector(
          key: const ValueKey('coloring-target'),
          onTap: _selected == null
              ? null
              : () {
                  setState(() => _painted = _selected);
                  if (_painted == _target) widget.onComplete();
                },
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 230,
              height: 230,
              child: Icon(
                Icons.star_rounded,
                size: 230,
                color: _painted ?? const Color(0xFFE7E9EF),
                shadows: const [
                  Shadow(color: Color(0x553A3A4A), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
      Wrap(
        spacing: 12,
        children: [
          for (final color in palette.values)
            Semantics(
              button: true,
              label: 'Color ${color.toARGB32()}',
              child: GestureDetector(
                onTap: () => setState(() => _selected = color),
                child: AnimatedContainer(
                  key: ValueKey('paint-${color.toARGB32()}'),
                  duration: const Duration(milliseconds: 150),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selected == color
                          ? const Color(0xFF34314A)
                          : Colors.white,
                      width: 5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}

class MatchingPairsGame extends StatefulWidget {
  const MatchingPairsGame({
    super.key,
    required this.activity,
    required this.onMatched,
    required this.onComplete,
  });
  final GameActivity activity;
  final ValueChanged<VocabularyEntry> onMatched;
  final VoidCallback onComplete;
  @override
  State<MatchingPairsGame> createState() => _MatchingPairsGameState();
}

class _MatchingPairsGameState extends State<MatchingPairsGame> {
  late final List<VocabularyEntry> _cards = [
    ...widget.activity.options,
    ...widget.activity.options,
  ]..shuffle();
  int? _first;
  final _matched = <String>{};
  bool _checking = false;
  Future<void> _tap(int index) async {
    if (_checking || _matched.contains(_cards[index].id) || _first == index) {
      return;
    }
    if (_first == null) {
      setState(() => _first = index);
      return;
    }
    final first = _first!;
    setState(() => _checking = true);
    if (_cards[first].id == _cards[index].id) {
      _matched.add(_cards[index].id);
      widget.onMatched(_cards[index]);
      setState(() {
        _first = null;
        _checking = false;
      });
      if (_matched.length == widget.activity.options.length) {
        widget.onComplete();
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _first = null;
          _checking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Text(
        'Match the pairs!',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      ),
      const Text('Tap two pictures that are the same'),
      const SizedBox(height: 10),
      Expanded(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final item = _cards[index];
            final active = _first == index || _matched.contains(item.id);
            return GestureDetector(
              key: ValueKey('match-$index-${item.id}'),
              onTap: () => _tap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _matched.contains(item.id)
                      ? const Color(0xFFD9F7E0)
                      : Colors.white,
                  border: Border.all(
                    color: active
                        ? const Color(0xFF4DBB78)
                        : const Color(0xFFE3DDF5),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Image.asset(item.imagePath!),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class CountingGame extends StatefulWidget {
  const CountingGame({
    super.key,
    required this.activity,
    required this.onAnswer,
  });
  final GameActivity activity;
  final GameAnswer onAnswer;
  @override
  State<CountingGame> createState() => _CountingGameState();
}

class _CountingGameState extends State<CountingGame> {
  int _tapped = 0;
  @override
  Widget build(BuildContext context) {
    final count = widget.activity.count ?? 1;
    return Column(
      children: [
        Text(
          '${widget.activity.target.english[0].toUpperCase()}${widget.activity.target.english.substring(1)}!',
          key: const ValueKey('game-prompt'),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const Text('Tap each star, then choose the number'),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < count; i++)
                  GestureDetector(
                    key: ValueKey('count-object-$i'),
                    onTap: () =>
                        setState(() => _tapped = math.max(_tapped, i + 1)),
                    child: Icon(
                      Icons.star_rounded,
                      size: 62,
                      color: i < _tapped
                          ? const Color(0xFFFFC83D)
                          : const Color(0xFFD8DCE6),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          children: [
            for (final number in [1, 2, 3, 4, 5])
              FilledButton(
                key: ValueKey('number-$number'),
                onPressed: () {
                  final item = number == count
                      ? widget.activity.target
                      : widget.activity.options.first;
                  widget.onAnswer(item, number == count && _tapped == count);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(55, 55),
                  padding: EdgeInsets.zero,
                ),
                child: Text('$number', style: const TextStyle(fontSize: 22)),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
