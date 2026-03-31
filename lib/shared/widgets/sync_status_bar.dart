import 'package:flutter/material.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/core/sync/sync_status.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final orchestrator = getIt<SyncOrchestrator>();

    return StreamBuilder<SyncStatus>(
      stream: orchestrator.statusStream,
      initialData: const SyncStatus.idle(),
      builder: (context, snapshot) {
        final status = snapshot.data!;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _buildContent(context, status, orchestrator),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    SyncStatus status,
    SyncOrchestrator orchestrator,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return status.when(
      idle: () => const SizedBox(key: ValueKey('idle')),
      syncing: () => _StatusContainer(
        key: const ValueKey('syncing'),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
        icon: const _RotatingSyncIcon(),
        text: 'Synchronizing vocabulary...',
        textColor: colorScheme.primary,
      ),
      error: (message) => GestureDetector(
        onTap: orchestrator.retrySync,
        behavior: HitTestBehavior.opaque,
        child: _StatusContainer(
          key: const ValueKey('error'),
          backgroundColor: colorScheme.error.withValues(alpha: 0.08),
          icon: Icon(
            Icons.sync_problem_rounded,
            color: colorScheme.error,
            size: 15,
          ),
          text: 'Sync error. Tap to retry.',
          textColor: colorScheme.error,
        ),
      ),
      offline: () => _StatusContainer(
        key: const ValueKey('offline'),
        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
        icon: Icon(
          Icons.cloud_off_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 15,
        ),
        text: 'Working offline',
        textColor: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _StatusContainer extends StatelessWidget {
  const _StatusContainer({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.text,
    required this.textColor,
  });

  final Color backgroundColor;
  final Widget icon;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: textColor.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingSyncIcon extends StatefulWidget {
  const _RotatingSyncIcon();

  @override
  State<_RotatingSyncIcon> createState() => _RotatingSyncIconState();
}

class _RotatingSyncIconState extends State<_RotatingSyncIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.sync_rounded,
        size: 15,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
