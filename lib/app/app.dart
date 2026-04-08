import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/history/presentation/blocs/history/history_bloc.dart';
import '../features/history/presentation/blocs/history/history_event.dart';
import '../features/lexicon/presentation/blocs/lexicon/lexicon_bloc.dart';
import '../features/lexicon/presentation/blocs/lexicon/lexicon_event.dart';
import '../features/text_analyzer/presentation/blocs/analyzer/analyzer_bloc.dart';
import '../core/navigation/app_navigator.dart';
import 'app_shell.dart';
import 'di/injection.dart';

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
