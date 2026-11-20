import 'package:material_ui/material_ui.dart';

class CloudBackground extends StatelessWidget {
  const CloudBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8F7FF), Color(0xFFFFF8E7)],
      ),
    ),
    child: Stack(
      children: [
        const Positioned(top: 36, left: -30, child: _Cloud(size: 130)),
        const Positioned(top: 145, right: -35, child: _Cloud(size: 105)),
        SafeArea(child: child),
      ],
    ),
  );
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Icon(
    Icons.cloud_rounded,
    size: size,
    color: Colors.white.withValues(alpha: 0.7),
  );
}
