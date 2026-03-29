import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_flow/core/theme/app_theme.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/vocabulary/presentation/blocs/sync_cubit.dart';
import 'package:word_flow/app/router/app_router.dart';
import 'package:word_flow/core/di/injection.dart';

class WordFlowApp extends StatelessWidget {
  const WordFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..init()),
        BlocProvider(create: (_) => getIt<SyncCubit>()..init()),
      ],
      child: MaterialApp.router(
        title: 'WordFlow',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
