import 'package:flutter/material.dart';

class WorkspaceBackground extends StatelessWidget {
  const WorkspaceBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface,
            scheme.surface.withValues(alpha: 0.92),
            scheme.surfaceContainerHighest.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _Glow(color: scheme.primary.withValues(alpha: 0.15)),
          ),
          Positioned(
            top: 170,
            left: -70,
            child: _Glow(
              color: scheme.secondary.withValues(alpha: 0.12),
              size: 180,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
