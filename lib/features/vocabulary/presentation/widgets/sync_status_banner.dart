import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/core/sync/sync_orchestrator.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_dead_letter_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/sync_issues_sheet.dart';

/// Enhanced sync status banner showing detailed sync states.
///
/// Displays contextual information about:
/// - Idle synced state (auto-dismisses "✓ Synced" after 2s)
/// - Offline state with pending count
/// - Active syncing with progress
/// - Sync errors with retry action
/// - Dead letter failures with review action
///
/// Placed below the AppBar in the workspace scaffold.
class SyncStatusBanner extends StatefulWidget {
  const SyncStatusBanner({super.key});

  @override
  State<SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends State<SyncStatusBanner> {
  Timer? _dismissTimer;
  bool _showSyncedMessage = false;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _startAutoDismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSyncedMessage = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deadLetterRepository = getIt<SyncDeadLetterRepository>();
    final orchestrator = getIt<SyncOrchestrator>();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, syncState) {
        return StreamBuilder<int>(
          stream: deadLetterRepository.watchDeadLetterCount(),
          initialData: 0,
          builder: (context, deadLetterSnapshot) {
            final deadLetterCount = deadLetterSnapshot.data ?? 0;

            // Determine banner state
            final bannerContent = _buildBannerContent(
              context: context,
              syncState: syncState,
              deadLetterCount: deadLetterCount,
              colorScheme: colorScheme,
              onRetry: orchestrator.retrySync,
              onReviewDeadLetters: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) =>
                      SyncIssuesSheet(repository: deadLetterRepository),
                );
              },
            );

            // Handle auto-dismiss for synced state
            if (syncState.maybeWhen(
              idle: (pendingCount, _, __) => pendingCount == 0,
              orElse: () => false,
            )) {
              if (!_showSyncedMessage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _showSyncedMessage = true);
                    _startAutoDismiss();
                  }
                });
              }
            } else {
              _dismissTimer?.cancel();
              if (mounted) {
                setState(() => _showSyncedMessage = false);
              }
            }

            // Show banner only if there's active state to display
            final shouldShowBanner =
                !(_showSyncedMessage ||
                    syncState.maybeWhen(
                      idle: (pendingCount, _, failure) =>
                          pendingCount == 0 && failure == null,
                      orElse: () => false,
                    ) ||
                    (deadLetterCount == 0 &&
                        syncState.maybeWhen(
                          idle: (_, __, ___) => true,
                          syncing: (_, __) => false,
                          error: (_, __, ___) => false,
                          orElse: () => false,
                        )));

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _showSyncedMessage
                  ? _buildSyncedMessage(colorScheme)
                  : (shouldShowBanner
                        ? bannerContent
                        : const SizedBox.shrink()),
            );
          },
        );
      },
    );
  }

  Widget _buildBannerContent({
    required BuildContext context,
    required SyncState syncState,
    required int deadLetterCount,
    required ColorScheme colorScheme,
    required VoidCallback onRetry,
    required VoidCallback onReviewDeadLetters,
  }) {
    return syncState.when(
      idle: (pendingCount, lastSyncTime, failure) {
        // Offline state with pending changes
        if (pendingCount > 0) {
          return _BannerContainer(
            backgroundColor: Colors.amber.shade50,
            borderColor: Colors.amber.shade200,
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.signal_cellular_off,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📡 Offline — $pendingCount change${pendingCount > 1 ? 's' : ''} pending',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          );
        }

        // Dead letter state (highest priority after offline)
        if (deadLetterCount > 0) {
          return GestureDetector(
            onTap: onReviewDeadLetters,
            child: _BannerContainer(
              backgroundColor: Colors.orange.shade50,
              borderColor: Colors.orange.shade200,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '⚠ $deadLetterCount word${deadLetterCount > 1 ? 's' : ''} failed to sync permanently — Tap to review',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.orange.shade800,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
      syncing: (pendingCount, failure) {
        return _BannerContainer(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
          borderColor: colorScheme.primary.withValues(alpha: 0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.sync, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Syncing $pendingCount change${pendingCount > 1 ? 's' : ''}...',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ],
          ),
        );
      },
      error: (pendingCount, message, failure) {
        return GestureDetector(
          onTap: onRetry,
          child: _BannerContainer(
            backgroundColor: colorScheme.error.withValues(alpha: 0.08),
            borderColor: colorScheme.error.withValues(alpha: 0.3),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠ Sync failed — Tap to retry',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncedMessage(ColorScheme colorScheme) {
    return _BannerContainer(
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade200,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '✓ Synced',
              style: TextStyle(
                color: Colors.green.shade900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Reusable banner container with consistent styling.
class _BannerContainer extends StatelessWidget {
  const _BannerContainer({
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(backgroundColor.toString()),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: child,
    );
  }
}
