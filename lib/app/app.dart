import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/app/app_shell.dart';
import 'package:lexitrack/app/di/injection.dart';
import 'package:lexitrack/core/navigation/app_navigator.dart';
import 'package:lexitrack/core/theme/app_theme.dart';
import 'package:lexitrack/core/theme/theme_cubit.dart';
import 'package:lexitrack/features/history/presentation/blocs/history/history_bloc.dart';
import 'package:lexitrack/features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import 'package:lexitrack/features/settings/presentation/blocs/backup/backup_bloc.dart';
import 'package:lexitrack/features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';

class LexiTrackApp extends StatelessWidget {
  const LexiTrackApp({super.key});

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
