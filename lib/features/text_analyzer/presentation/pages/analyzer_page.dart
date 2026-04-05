import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/common/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../lexicon/presentation/bloc/lexicon_bloc.dart';
import '../../../lexicon/presentation/bloc/lexicon_event.dart';
import '../bloc/analyzer_bloc.dart';
import '../bloc/analyzer_event.dart';
import '../bloc/analyzer_state.dart';
import '../widgets/analysis_summary.dart';

class AnalyzerPage extends StatefulWidget {
  const AnalyzerPage({super.key});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    final rawTitle = _titleCtrl.text.trim();
    final title = rawTitle.isEmpty 
        ? 'Analysis - ${DateFormat('MMM dd, HH:mm').format(DateTime.now())}' 
        : rawTitle;

    context.read<AnalyzerBloc>().add(
          StartAnalysis(
            title: title,
            content: _contentCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText.headline('Text Analyzer'),
        actions: const [ThemeToggle(), SizedBox(width: 8)],
      ),
      body: BlocConsumer<AnalyzerBloc, AnalyzerState>(
        listener: (context, state) {
          if (state.status.isFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: AppText(state.status.error ?? 'Error')),
            );
          }
        },
        builder: (context, state) => state.status.when(
          initial: () => _InputBody(
            titleCtrl: _titleCtrl,
            contentCtrl: _contentCtrl,
            onAnalyze: _onAnalyze,
          ),
          failure: (_) => _InputBody(
            titleCtrl: _titleCtrl,
            contentCtrl: _contentCtrl,
            onAnalyze: _onAnalyze,
          ),
          loading: () => const AppLoader(message: 'Processing text...'),
          success: (result) => AnalysisSummary(
            result: result,
            onReset: () {
              _titleCtrl.clear();
              _contentCtrl.clear();
              context.read<AnalyzerBloc>().add(const ResetAnalysis());
            },
            onToggleStatus: (w) {
              final lexiconBloc = context.read<LexiconBloc>();
              final analyzerBloc = context.read<AnalyzerBloc>();

              lexiconBloc.add(ToggleWordStatusEvent(w.word.id));
              analyzerBloc.add(ToggleWordStatusInResult(wordId: w.word.id));
            },
          ),
        ),
      ),
    );
  }
}

class _InputBody extends StatelessWidget {
  const _InputBody({
    required this.titleCtrl,
    required this.contentCtrl,
    required this.onAnalyze,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText.headline('New Analysis'),
          const SizedBox(height: 16),
          AppTextField(
            controller: titleCtrl,
            label: 'Title (Optional)',
            hint: 'e.g., Short Story, News Article',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: contentCtrl,
            label: 'Text to Analyze',
            hint: 'Paste English text here...',
            maxLines: 15,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Analyze Text',
            onPressed: onAnalyze,
            icon: Icons.analytics_outlined,
          ),
        ],
      ),
    );
  }
}
