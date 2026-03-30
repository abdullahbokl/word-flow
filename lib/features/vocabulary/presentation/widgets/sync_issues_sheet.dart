import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/database/app_database.dart';
import 'package:word_flow/features/vocabulary/data/repositories/sync_dead_letter_repository.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';

class SyncIssuesSheet extends StatefulWidget {
  const SyncIssuesSheet({super.key, required this.repository});

  final SyncDeadLetterRepository repository;

  @override
  State<SyncIssuesSheet> createState() => _SyncIssuesSheetState();
}

class _SyncIssuesSheetState extends State<SyncIssuesSheet> {
  bool _isLoading = true;
  String? _error;
  List<SyncDeadLetter> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.repository.getDeadLetters();
    result.fold(
      (failure) {
        if (!mounted) return;
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (items) {
        if (!mounted) return;
        setState(() {
          _items = items;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _retryItem(SyncDeadLetter item) async {
    final result = await widget.repository.requeueDeadLetter(item.id);
    result.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Retry failed: ${failure.message}')),
        );
      },
      (_) {
        if (!mounted) return;
        context.read<SyncCubit>().syncNow();
        unawaited(_load());
      },
    );
  }

  Future<void> _dismissItem(SyncDeadLetter item) async {
    final result = await widget.repository.acknowledgeDeadLetter(item.id);
    result.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dismiss failed: ${failure.message}')),
        );
      },
      (_) {
        if (!mounted) return;
        unawaited(_load());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: scheme.error),
                const SizedBox(width: 8),
                Text(
                  'Sync Issues',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These items failed permanently and need manual action.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: TextStyle(color: scheme.error)),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No unresolved sync issues.'),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _SyncIssueRow(
                      item: item,
                      onRetry: () => unawaited(_retryItem(item)),
                      onDismiss: () => unawaited(_dismissItem(item)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SyncIssueRow extends StatelessWidget {
  const _SyncIssueRow({
    required this.item,
    required this.onRetry,
    required this.onDismiss,
  });

  final SyncDeadLetter item;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.wordText, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Operation: ${item.operation}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          item.lastError,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.error),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
          ],
        ),
      ],
    );
  }
}
