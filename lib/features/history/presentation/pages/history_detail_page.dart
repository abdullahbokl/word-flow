import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/status_view.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../../core/widgets/word_list_section.dart';
import '../../domain/entities/history_detail.dart';
import '../blocs/history_detail/history_detail_bloc.dart';
import '../blocs/history_detail/history_detail_event.dart';
import '../blocs/history_detail/history_detail_state.dart';
import '../widgets/history_detail_stats_grid.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({required this.id, super.key});
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
        actions: const [ThemeToggle(), SizedBox(width: AppDimensions.space8)],
      ),
      body: BlocBuilder<HistoryDetailBloc, HistoryDetailState>(
        builder: (context, state) => StatusView<HistoryDetail>(
          status: state.status,
          onInitial: () => const AppLoader(),
          onLoading: () => const AppLoader(),
          onFailure: (e) => Center(child: AppText.body(e)),
          onSuccess: (detail) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.headline(detail.item.title, fontWeight: FontWeight.bold),
                      const SizedBox(height: AppDimensions.space8),
                      const AppText.label('Full text content excerpt:'),
                      _SnippetBox(snippet: detail.item.contentSnippet, isDark: isDark),
                      const SizedBox(height: AppDimensions.space24),
                      HistoryDetailStatsGrid(detail: detail),
                      const SizedBox(height: AppDimensions.space32),
                      WordListSection(
                        words: detail.words,
                        onToggleStatus: (w) => context.read<HistoryDetailBloc>().add(ToggleWordStatusInHistory(w.word.id)),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.space32)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnippetBox extends StatelessWidget {
  const _SnippetBox({required this.snippet, required this.isDark});
  final String snippet;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText.body(
        snippet,
        fontStyle: FontStyle.italic,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
      ),
    );
  }
}
