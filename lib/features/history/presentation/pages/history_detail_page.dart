import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/word_list_section.dart';
import '../bloc/history_detail_bloc.dart';
import '../bloc/history_detail_event.dart';
import '../bloc/history_detail_state.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HistoryDetailBloc>()..add(LoadHistoryDetail(id)),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Detail'),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
        builder: (context, state) => switch (state) {
          HistoryDetailInitial() || HistoryDetailLoading() => const AppLoader(),
          HistoryDetailFailure(:final message) => Center(child: Text(message)),
          HistoryDetailLoaded(:final detail) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.item.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Full text content excerpt:',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            detail.item.contentSnippet,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _StatsGrid(detail: detail),
                        const SizedBox(height: 32),
                        WordListSection(words: detail.words),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.detail});
  final dynamic detail; // HistoryDetail

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _StatCard(
          label: 'Total Words',
          value: '${detail.item.totalWords}',
          icon: Icons.article_outlined,
          color: AppColors.primary,
        ),
        _StatCard(
          label: 'Unique Words',
          value: '${detail.item.uniqueWords}',
          icon: Icons.abc,
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
