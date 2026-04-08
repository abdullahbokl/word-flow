import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/status_view.dart';
import '../../../lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import '../../../lexicon/presentation/blocs/lexicon/lexicon_event.dart';
import '../blocs/analyzer/analyzer_bloc.dart';
import '../blocs/analyzer/analyzer_event.dart';
import '../blocs/analyzer/analyzer_state.dart';
import '../../domain/entities/analysis_result.dart';
import '../widgets/analysis_summary.dart';
import '../widgets/analyzer_input_body.dart';

class AnalyzerPage extends StatefulWidget {
  const AnalyzerPage({super.key});

  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> with AutomaticKeepAliveClientMixin {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AnalyzerBloc, AnalyzerState>(
          listener: (context, state) {
            if (state.status.isFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AppText(state.status.error ?? AppStrings.error)),
              );
            }
          },
          builder: (context, state) => StatusView<AnalysisResult>(
            status: state.status,
            onInitial: () => AnalyzerInputBody(
              titleCtrl: _titleCtrl,
              contentCtrl: _contentCtrl,
              onAnalyze: _onAnalyze,
            ),
            onFailure: (_) => AnalyzerInputBody(
              titleCtrl: _titleCtrl,
              contentCtrl: _contentCtrl,
              onAnalyze: _onAnalyze,
            ),
            onLoading: () => const AppLoader(message: 'Processing text...'),
            onSuccess: (result) => AnalysisSummary(
              result: result,
              onReset: () {
                _titleCtrl.clear();
                _contentCtrl.clear();
                context.read<AnalyzerBloc>().add(const ResetAnalysis());
              },
              onToggleStatus: (w) {
                context.read<LexiconBloc>().add(ToggleWordStatusEvent(w.word.id));
                context.read<AnalyzerBloc>().add(ToggleWordStatusInResult(wordId: w.word.id));
              },
            ),
          ),
        ),
      ),
    );
  }
}
