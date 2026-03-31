import 'dart:async';

import 'package:flutter/material.dart';

class ScriptProcessingProgressOverlay extends StatefulWidget {
  const ScriptProcessingProgressOverlay({
    super.key,
    required this.isProcessing,
    required this.progress,
    required this.totalWords,
  });

  final bool isProcessing;
  final double progress;
  final int totalWords;

  @override
  State<ScriptProcessingProgressOverlay> createState() =>
      _ScriptProcessingProgressOverlayState();
}

class _ScriptProcessingProgressOverlayState
    extends State<ScriptProcessingProgressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  Timer? _dismissTimer;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  void didUpdateWidget(covariant ScriptProcessingProgressOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isProcessing && !widget.isProcessing) {
      _dismissTimer?.cancel();
      setState(() => _showSuccess = true);
      _controller.forward(from: 0);
      _dismissTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() => _showSuccess = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = widget.progress.clamp(0.0, 1.0);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: widget.isProcessing
          ? Container(
              key: const ValueKey<String>('processing'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analyzing ${widget.totalWords} words...',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label:
                        'Processing script, ${(progress * 100).toInt()}% complete',
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(999),
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : (_showSuccess
                ? Container(
                    key: const ValueKey<String>('success'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _scale,
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analysis complete',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            color: Colors.green.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey<String>('hidden'))),
    );
  }
}
