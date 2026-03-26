import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/words/presentation/pages/workspace_page.dart';
import '../features/words/presentation/cubit/sync_cubit.dart';
import 'di.dart';

class WordFlowApp extends StatelessWidget {
  const WordFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<SyncCubit>()),
      ],
      child: MaterialApp(
        title: 'WordFlow',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const WorkspacePage(),
      ),
    );
  }
}
