import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lexitrack/core/constants/app_strings.dart';
import 'package:lexitrack/core/utils/ui_utils.dart';
import 'package:lexitrack/core/widgets/app_loader.dart';
import 'package:lexitrack/core/widgets/status_view.dart';
import 'package:lexitrack/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:lexitrack/features/text_analyzer/domain/entities/analysis_result.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_event.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_state.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/analysis_summary.dart';
import 'package:lexitrack/features/text_analyzer/presentation/widgets/analyzer_input_body.dart';
import 'package:path/path.dart' as p;

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

  Future<void> _onPickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final fileName = result.files.single.name;
        
        setState(() {
          _titleCtrl.text = p.basenameWithoutExtension(fileName);
          _contentCtrl.text = content;
        });
      }
    } catch (e) {
      if (mounted) {
        AppUIUtils.showSnackBar(
          context,
          message: AppStrings.fileError,
        );
      }
    }
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
        child: MultiBlocListener(
          listeners: [
            BlocListener<AnalyzerBloc, AnalyzerState>(
              listener: (context, state) {
                if (state.status.isFailed) {
                  AppUIUtils.showSnackBar(
                    context,
                    message: state.status.error ?? AppStrings.error,
                  );
                }
                if (state.status.isSuccess) {
                  context.read<LexiconBloc>().add(const LoadLexicon());
                  context.read<HistoryBloc>().add(const LoadHistory());
                }
              },
            ),
            BlocListener<LexiconBloc, LexiconState>(
              listener: (context, lexiconState) {
                // Trigger sync when Lexicon successfully updates, as statuses might have changed
                if (lexiconState.status.isSuccess) {
                  context
                      .read<AnalyzerBloc>()
                      .add(const SyncCurrentResultWithLexicon());
                }
              },
            ),
          ],
          child: BlocBuilder<AnalyzerBloc, AnalyzerState>(
            builder: (context, state) => StatusView<AnalysisResult>(
              status: state.status,
              animate: false,
              onInitial: () => AnalyzerInputBody(
                titleCtrl: _titleCtrl,
                contentCtrl: _contentCtrl,
                onAnalyze: _onAnalyze,
                onPickFile: _onPickFile,
              ),
              onFailure: (_) => AnalyzerInputBody(
                titleCtrl: _titleCtrl,
                contentCtrl: _contentCtrl,
                onAnalyze: _onAnalyze,
                onPickFile: _onPickFile,
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
                  context
                      .read<LexiconBloc>()
                      .add(ToggleWordStatusEvent(w.word.id));
                  context
                      .read<AnalyzerBloc>()
                      .add(ToggleWordStatusInResult(wordId: w.word.id));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
