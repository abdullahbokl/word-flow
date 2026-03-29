import 'package:go_router/go_router.dart';
import 'package:word_flow/app/router/routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/workspace',
    routes: $appRoutes,
  );
}
