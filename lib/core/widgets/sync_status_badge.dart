import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/di/injection.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_dead_letter_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_state.dart';
import 'package:word_flow/features/vocabulary/presentation/widgets/sync_issues_sheet.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({super.key});

  void _showIssuesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          SyncIssuesSheet(repository: getIt<SyncDeadLetterRepository>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadLetterRepository = getIt<SyncDeadLetterRepository>();

    return StreamBuilder<int>(
      stream: deadLetterRepository.watchDeadLetterCount(),
      initialData: 0,
      builder: (context, deadLetterSnapshot) {
        final deadLetterCount = deadLetterSnapshot.data ?? 0;

        return BlocBuilder<SyncCubit, SyncState>(
          builder: (context, state) {
            final scheme = Theme.of(context).colorScheme;
            final hasSyncIssues = deadLetterCount > 0;

            final badge = state.map(
              idle: (s) => _Badge(
                icon: Icons.cloud_done_rounded,
                color: s.pendingCount == 0 ? scheme.primary : scheme.secondary,
                label: s.pendingCount == 0
                    ? 'Synced'
                    : '${s.pendingCount} pending',
                onTap: hasSyncIssues
                    ? () => _showIssuesSheet(context)
                    : s.pendingCount > 0
                    ? () => context.read<SyncCubit>().syncNow()
                    : null,
              ),
              syncing: (s) => _Badge(
                icon: Icons.sync_rounded,
                color: scheme.primary,
                label: 'Syncing...',
                isRotating: true,
                onTap: hasSyncIssues ? () => _showIssuesSheet(context) : null,
              ),
              error: (e) => _Badge(
                icon: Icons.sync_problem_rounded,
                color: scheme.error,
                label: 'Sync error',
                onTap: hasSyncIssues
                    ? () => _showIssuesSheet(context)
                    : () => context.read<SyncCubit>().syncNow(),
              ),
            );

            if (!hasSyncIssues) {
              return badge;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                badge,
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
    this.isRotating = false,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;
  final bool isRotating;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRotating)
              RotationTransition(
                turns: const AlwaysStoppedAnimation(0.5),
                child: Icon(icon, size: 14, color: color),
              )
            else
              Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
