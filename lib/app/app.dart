import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/app/app_shell.dart';
import 'package:wordflow/app/di/injection.dart';
import 'package:wordflow/core/navigation/app_navigator.dart';
import 'package:wordflow/core/theme/app_theme.dart';
import 'package:wordflow/core/theme/theme_cubit.dart';
import 'package:wordflow/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:wordflow/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:wordflow/features/settings/presentation/blocs/backup/backup_bloc.dart';
import 'package:wordflow/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';

class WordFlowApp extends StatelessWidget {
  const WordFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(
          create: (_) => sl<LexiconBloc>()..add(const LoadLexicon()),
        ),
        BlocProvider(create: (_) => sl<AnalyzerBloc>()),
        BlocProvider(
          create: (_) => sl<HistoryBloc>()..add(const LoadHistory()),
        ),
        BlocProvider(
          create: (_) => sl<BackupBloc>()..add(CheckBackupStatus()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'WordFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            navigatorKey: AppNavigator.key,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
