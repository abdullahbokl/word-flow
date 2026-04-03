import 'package:go_router/go_router.dart';
import 'package:word_flow/app/router/routes.dart';
import 'package:word_flow/app/router/error_page.dart';
import 'package:word_flow/core/di/injection.dart';

class AppRouter {
  AppRouter();

  GoRouter get router {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      routes: $appRoutes,
      errorBuilder: (context, state) => ErrorPage(error: state.error),
      redirect: (context, state) {
        // Prevent navigation to invalid routes
        return null;
      },
    );
  }
}
