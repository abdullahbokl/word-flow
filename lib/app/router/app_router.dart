import 'package:go_router/go_router.dart';
import 'package:word_flow/app/router/routes.dart';
import 'package:word_flow/app/router/error_page.dart';
import 'package:word_flow/features/authentication/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/core/utils/router_utils.dart';
import 'package:word_flow/core/di/injection.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: StreamToListenable(getIt<AuthCubit>().stream),
    routes: $appRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
    redirect: (context, state) {
      final authState = getIt<AuthCubit>().state;
      
      final isSplashing = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/auth';

      return authState.maybeMap(
        initial: (_) => isSplashing ? null : '/splash',
        loading: (_) => isSplashing ? null : '/splash',
        authenticated: (_) {
          if (isSplashing || isLoggingIn) return '/workspace';
          return null;
        },
        guest: (_) {
          if (isSplashing || isLoggingIn) return '/workspace';
          return null;
        },
        orElse: () => null,
      );
    },
  );
}
