import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/status_view.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../../core/widgets/word_list_section.dart';
import '../../domain/entities/history_detail.dart';
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
        title: const AppText.title('Analysis Detail'),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
        builder: (context, state) => StatusView<HistoryDetail>(
          status: state.status,
          onInitial: () => const AppLoader(),
          onLoading: () => const AppLoader(),
          onFailure: (error) => Center(child: AppText.body(error)),
          onSuccess: (detail) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.headline(
                        detail.item.title,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      const AppText.label('Full text content excerpt:'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText.body(
                          detail.item.contentSnippet,
                          fontStyle: FontStyle.italic,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatsGrid(detail: detail),
                      const SizedBox(height: 32),
                      WordListSection(
                        words: detail.words,
                        onToggleStatus: (w) =>
                            context.read<HistoryDetailBloc>().add(
                                  ToggleWordStatusInHistory(w.word.id),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.detail});
  final HistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StatCard(
          label: 'Total Words',
          value: '${detail.item.totalWords}',
          color: AppColors.primary,
        ),
        StatCard(
          label: 'Unique Words',
          value: '${detail.item.uniqueWords}',
          color: AppColors.secondary,
        ),
        StatCard(
          label: 'Known Words',
          value: '${detail.item.knownWords}',
          color: AppColors.success,
        ),
        StatCard(
          label: 'Unknown',
          value: '${detail.item.unknownWords}',
          color: AppColors.error,
        ),
      ],
    );
  }
}
