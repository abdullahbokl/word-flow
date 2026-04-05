import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/pages/history_detail_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/lexicon/presentation/pages/lexicon_page.dart';
import '../features/text_analyzer/presentation/pages/analyzer_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/analyzer',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/analyzer',
          builder: (context, state) => const AnalyzerPage(),
        ),
        GoRoute(
          path: '/lexicon',
          builder: (context, state) => const LexiconPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return HistoryDetailPage(id: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. If there's an internal navigator stack (e.g., detail page), handle normal pop
        final shellNav = _shellNavigatorKey.currentState;
        if (shellNav != null && shellNav.canPop()) {
          shellNav.pop();
          return;
        }

        // 2. We are on a secondary tab root, return to Analyzer (Home)
        final currentLocation = GoRouterState.of(context).uri.path;
        if (currentLocation != '/analyzer' && currentLocation != '/') {
          context.go('/analyzer');
          return;
        }

        // 3. We are already on home root, show exit confirmation
        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: switch (location) {
            '/analyzer' => 0,
            '/lexicon' => 1,
            '/history' => 2,
            _ => location.startsWith('/history') ? 2 : 0,
          },
          onTap: (index) {
            final target = switch (index) {
              0 => '/analyzer',
              1 => '/lexicon',
              2 => '/history',
              _ => '/analyzer',
            };
            context.go(target);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analyzer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Lexicon',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit lexitrack?'),
        content: const Text('Are you sure you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
