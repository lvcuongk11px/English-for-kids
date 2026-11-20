import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

enum PinkyMood { idle, hello, listening, happy, encourage, celebrate, sleep }

class PinkyMascot extends StatefulWidget {
  const PinkyMascot({super.key, this.mood = PinkyMood.idle, this.size = 120});
  final PinkyMood mood;
  final double size;
  @override
  State<PinkyMascot> createState() => _PinkyMascotState();
}

class _PinkyMascotState extends State<PinkyMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Semantics(
      label: 'Pinky the pink pig, ${widget.mood.name}',
      image: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final active =
              widget.mood == PinkyMood.celebrate ||
              widget.mood == PinkyMood.hello ||
              widget.mood == PinkyMood.happy;
          return Transform.translate(
            offset: Offset(
              0,
              active ? -5 * math.sin(_controller.value * math.pi) : 0,
            ),
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _PinkyPainter(widget.mood),
            ),
          );
        },
      ),
    ),
  );
}

class _PinkyPainter extends CustomPainter {
  _PinkyPainter(this.mood);
  final PinkyMood mood;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 120;
    canvas.scale(s, s);
    final outline = Paint()
      ..color = const Color(0xFF8E5264)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final pink = Paint()..color = const Color(0xFFFFAFC4);
    final pale = Paint()..color = const Color(0xFFFFCAD7);
    final cheek = Paint()..color = const Color(0xFFF67FA1);
    canvas.drawOval(const Rect.fromLTWH(27, 52, 66, 58), pink);
    canvas.drawOval(const Rect.fromLTWH(20, 18, 80, 76), pink);
    final leftEar = Path()
      ..moveTo(30, 28)
      ..lineTo(24, 4)
      ..quadraticBezierTo(44, 8, 47, 23)
      ..close();
    final rightEar = Path()
      ..moveTo(73, 22)
      ..quadraticBezierTo(82, 5, 98, 7)
      ..lineTo(91, 34)
      ..close();
    canvas.drawPath(leftEar, pink);
    canvas.drawPath(rightEar, pink);
    canvas.drawPath(leftEar, outline);
    canvas.drawPath(rightEar, outline);
    canvas.drawOval(const Rect.fromLTWH(20, 18, 80, 76), outline);
    canvas.drawOval(const Rect.fromLTWH(27, 52, 66, 58), outline);
    final sleeping = mood == PinkyMood.sleep;
    if (sleeping) {
      canvas.drawArc(
        const Rect.fromLTWH(39, 43, 13, 8),
        0,
        math.pi,
        false,
        outline,
      );
      canvas.drawArc(
        const Rect.fromLTWH(68, 43, 13, 8),
        0,
        math.pi,
        false,
        outline,
      );
    } else {
      canvas.drawOval(
        const Rect.fromLTWH(40, 38, 12, 16),
        Paint()..color = Colors.white,
      );
      canvas.drawOval(
        const Rect.fromLTWH(68, 38, 12, 16),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        const Offset(47, 47),
        3.5,
        Paint()..color = const Color(0xFF473440),
      );
      canvas.drawCircle(
        const Offset(73, 47),
        3.5,
        Paint()..color = const Color(0xFF473440),
      );
    }
    canvas.drawCircle(const Offset(35, 62), 7, cheek);
    canvas.drawCircle(const Offset(85, 62), 7, cheek);
    canvas.drawOval(const Rect.fromLTWH(45, 55, 30, 22), pale);
    canvas.drawOval(const Rect.fromLTWH(45, 55, 30, 22), outline);
    canvas.drawOval(const Rect.fromLTWH(52, 62, 4, 6), cheek);
    canvas.drawOval(const Rect.fromLTWH(64, 62, 4, 6), cheek);
    if (mood == PinkyMood.encourage) {
      canvas.drawArc(
        const Rect.fromLTWH(51, 73, 18, 10),
        math.pi,
        math.pi,
        false,
        outline,
      );
    } else if (sleeping) {
      canvas.drawCircle(const Offset(60, 82), 3, outline);
    } else {
      canvas.drawArc(
        const Rect.fromLTWH(49, 70, 22, 14),
        0,
        math.pi,
        false,
        outline,
      );
    }
    final armY = mood == PinkyMood.hello
        ? 53.0
        : mood == PinkyMood.happy || mood == PinkyMood.celebrate
        ? 67.0
        : 79.0;
    canvas.drawLine(const Offset(31, 73), Offset(13, armY), outline);
    canvas.drawLine(
      const Offset(89, 73),
      Offset(107, 79 - (armY - 79)),
      outline,
    );
    canvas.drawLine(const Offset(45, 106), const Offset(43, 117), outline);
    canvas.drawLine(const Offset(75, 106), const Offset(77, 117), outline);
    if (mood == PinkyMood.listening) {
      canvas.drawArc(
        const Rect.fromLTWH(82, 37, 15, 21),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFF6657D9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
    if (mood == PinkyMood.celebrate) {
      final sparkle = Paint()
        ..color = const Color(0xFFFFC83D)
        ..strokeWidth = 3;
      for (final p in [
        const Offset(12, 25),
        const Offset(108, 24),
        const Offset(104, 58),
      ]) {
        canvas.drawLine(
          p - const Offset(5, 0),
          p + const Offset(5, 0),
          sparkle,
        );
        canvas.drawLine(
          p - const Offset(0, 5),
          p + const Offset(0, 5),
          sparkle,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PinkyPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
