import 'package:go_router/go_router.dart';
import 'package:word_flow/app/router/routes.dart';
import 'package:word_flow/app/router/error_page.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/core/utils/router_utils.dart';
import 'package:word_flow/core/di/injection.dart';

class AppRouter {
  AppRouter(this._authCubit);

  final AuthCubit _authCubit;

  GoRouter get router {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: StreamToListenable(_authCubit.stream),
      routes: $appRoutes,
      errorBuilder: (context, state) => ErrorPage(error: state.error),
      redirect: (context, state) => redirectForLocation(state.matchedLocation),
    );
  }

  String? redirectForLocation(String matchedLocation) {
    final authState = _authCubit.state;

    final isSplashing = matchedLocation == '/splash';
    final isLoggingIn = matchedLocation == '/auth';
    final isResetPassword = matchedLocation == '/reset-password';

    return authState.maybeMap(
      initial: (_) => isSplashing ? null : '/splash',
      loading: (_) => isSplashing ? null : '/splash',
      passwordRecovery: (_) => isResetPassword ? null : '/reset-password',
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
  }
}
